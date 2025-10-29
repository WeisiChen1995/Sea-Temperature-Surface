################################################################################
# Project: Modelling Australian Sea Suface Temperature (SST) from 1995 to 2005##
# File aim: Make an animation to visualize the montly changes to SST from 1995 to 2005
# Input data: "2-data\sst.mnmean.nc" downloaded from https://downloads.psl.noaa.gov/Datasets/noaa.ersst.v5/sst.mnmean.nc
# output data: "3-output\sst_1995_2025.gif" ####################################
# Author: Weisi Chen ###########################################################
# Data started: 26 October 2025 ################################################
################################################################################

library(terra)
library(ncdf4)
library(httr)
library(dplyr)
library(lubridate)
library(readr)
library(sp)
library(gstat)
library(geoR)
library(ggplot2)
library(viridis)
library(here)
library(rnaturalearth)
library(sf)
library(gganimate)

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
# Convert to Date class if needed
# E.g. assume monthly time stamps

sst_sub <- sst_region

########plot movie#########
# Create sequence of dates corresponding to raster layers
start_date <- as.Date("1854-01-01")
dates <- seq.Date(start_date, by = "month", length.out = nlyr(sst_region))

# Find indices for 2010-01 to 2025-12
idx <- which(dates >= as.Date("1995-01-01") & dates <= as.Date("2025-12-31"))

# Subset raster
sst_sub <- sst_region[[idx]]

# Corresponding dates
dates_sub <- dates[idx]

grid_list <- vector("list", nlyr(sst_sub))

for (i in 1:nlyr(sst_sub)) {
  tmp <- as.data.frame(sst_sub[[i]], xy = TRUE)
  colnames(tmp) <- c("Longitude", "Latitude", "SST")
  tmp <- tmp[!is.na(tmp$SST), ]
  tmp$Date <- dates_sub[i]
  grid_list[[i]] <- tmp
}

grid_all <- bind_rows(grid_list)

# Australia polygon
aus_sf <- ne_countries(country = "Australia", scale = "medium", returnclass = "sf")

p <- ggplot() +
  geom_raster(data = grid_all, aes(x = Longitude, y = Latitude, fill = SST)) +
  geom_sf(data = aus_sf, fill = "gray95", color = "gray40") +
  scale_fill_viridis(option = "C", name = "SST (°C)") +
  coord_sf(xlim = range(grid_all$Longitude), ylim = range(grid_all$Latitude)) +
  theme_minimal(base_size = 14) +
  theme(
    panel.grid = element_blank(),
    axis.text = element_text(color = "gray20"),
    axis.title = element_text(face = "bold"),
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5)
  ) +
  labs(x = "Longitude", y = "Latitude") +
  transition_time(Date) +
  labs(title = 'SST: {frame_time}')

# Animate
anim <- animate(p, nframes = nlyr(sst_sub), fps = 5, width = 800, height = 600)
anim_save("sst_1995_2025.gif", anim)
