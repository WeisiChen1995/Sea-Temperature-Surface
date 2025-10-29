################################################################################
# Project: Modelling Australian Sea Suface Temperature (SST) from 1995 to 2005##
# File aim: Applying statistical techniques, Principal Component Analysis (PCA), to identify dominant temperature patterns and variability modes.
# Input data: "2-data\sst.mnmean.nc" downloaded from https://downloads.psl.noaa.gov/Datasets/noaa.ersst.v5/sst.mnmean.nc
# output data: "3-Output/sst_plot.png" #########################################
# Author: Weisi Chen ###########################################################
# Data started: 26 October 2025 ################################################
################################################################################

library(terra)
library(dplyr)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
library(ggplot2)
library(viridis)
library(lubridate)
library(ggpubr)
library(here)

# Load the data
# Define file location: example for global monthly SST
# url <- "https://downloads.psl.noaa.gov/Datasets/noaa.ersst.v5/sst.mnmean.nc"  
# This file contains global monthly SST from Jan 1854 to present. :contentReference[oaicite:2]{index=2}

# Download
destfile <- "2-data/sst.mnmean.nc"
if (!file.exists(destfile)) download.file(url, destfile, mode="wb")

# Load with terra
sst_all <- rast(destfile)

# Define region around Australia (example)
lon_min <- 90; lon_max <- 190
lat_min <- -60; lat_max <- 20

# Crop spatially
sst_region <- crop(sst_all, ext(lon_min, lon_max, lat_min, lat_max))

# Subset time
time_vals <- time(sst_region)

sst_sub <- sst_region

# Create sequence of dates corresponding to raster layers
start_date <- as.Date("1854-01-01")
dates <- seq.Date(start_date, by = "month", length.out = nlyr(sst_region))

# Find indices for 1995-01 to 2025-12
idx <- which(dates >= as.Date("1945-01-01") & dates <= as.Date("2025-12-31"))

# Subset raster
sst_sub <- sst_region[[idx]]


# Convert to data.frame
df <- as.data.frame(sst_sub, xy=TRUE)  
# Columns: x, y, sst_1, sst_2, ..., sst_2061

# Remove x,y if you only want values
sst_vals <- df %>% select(-x, -y)  

# Transpose: rows = time, columns = locations
mat <- t(as.matrix(sst_vals))  

dim(mat)


# Identify non-NA columns
good_cols <- which(colSums(is.na(mat)) == 0)

# Subset to valid ocean cells
mat_ocean <- mat[, good_cols]

# Center each grid cell (remove mean)
mat_anom <- scale(mat_ocean, center = TRUE, scale = FALSE)  # anomalies

mat_std <- scale(mat_anom, center = FALSE, scale = TRUE)  # unit variance per cell

pca <- prcomp(mat_std, center = FALSE, scale. = FALSE)
var_exp <- (pca$sdev^2) / sum(pca$sdev^2)
round(var_exp[1:5]*100, 2)
# PCA1: 69.79

# PC1 time series
pc1 <- pca$x[,1]

# EOF1 spatial pattern
eof1 <- pca$rotation[,1]

# ------------------------
# Map EOF1
# ------------------------
template <- sst_sub[[1]]   # first layer as template
values(template) <- NA
values(template)[good_cols] <- eof1

grid <- as.data.frame(template, xy = TRUE)
colnames(grid) <- c("Longitude","Latitude","EOF1")
grid <- grid[!is.na(grid$EOF1),]

# Australia polygon
aus_sf <- ne_countries(country = "Australia", scale = "medium", returnclass = "sf")

g1 <- ggplot() +
  geom_raster(data = grid, aes(x=Longitude, y=Latitude, fill=EOF1)) +
  geom_sf(data = aus_sf, fill="gray95", color="gray40") +
  scale_fill_viridis(option="C", name="EOF1") +
  coord_sf(xlim = range(grid$Longitude), ylim = range(grid$Latitude)) +
  theme_minimal(base_size = 14) +
  labs(title = "EOF1 Spatial Pattern (Dominant SST Mode)",
       x = "Longitude", y = "Latitude")

# ------------------------
# Plot PC1 time series
# ------------------------
# Prepare PC1 plots
# B: Full 1995-2025
pc1_df <- data.frame(
  Date = dates[idx],  # same dates you used to subset SST
  PC1 = pc1
)

g2_full <- ggplot(pc1_df, aes(x = Date, y = PC1)) +
  geom_line(color = "steelblue", size = 1) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  scale_x_date(date_labels = "%Y", date_breaks = "2 years") +
  theme_minimal(base_size = 12) +
  labs(title = "PC1 Time Series (1995–2025)", x = "Year", y = "PC1 (Standardized)")

# C: Last 2 years
pc1_df_sub <- pc1_df %>% filter(Date >= as.Date("2024-01-01"))
g3_last2 <- ggplot(pc1_df_sub, aes(x = Date, y = PC1)) +
  geom_line(color = "steelblue", size = 1) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  scale_x_date(date_labels = "%b %Y", date_breaks = "1 month") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "PC1 Time Series (Last 2 Years)", x = "Month", y = "PC1 (Standardized)")

# Stack g2 and g3 vertically
right_side <- ggarrange(g2_full, g3_last2, ncol = 1, nrow = 2, labels = c("B", "C"))

# Combine with map (g1) on left
final_plot <- ggarrange(
  g1, right_side,
  ncol = 2, nrow = 1,
  labels = c("A", "")
)

# Show the combined figure
final_plot

###############################################################################
# Save the output

ggsave(here::here("3-Output/sst_plot.png"), plot = final_plot, width = 12, height = 6, dpi = 300)


