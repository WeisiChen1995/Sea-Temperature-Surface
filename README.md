# 🌊 Australian Sea Surface Temperature Analysis (1995–2025)

View it here[https://weisichen.org/sst.html]

Explore **30 years of sea surface temperature (SST) variability around Australia** using NOAA’s **ERSST** dataset. This project applies **Principal Component Analysis (PCA)** to reveal dominant spatial and temporal SST patterns and visualizes trends over time.  

---

## 📌 Overview
Sea surface temperature is a key indicator of ocean and climate variability, impacting weather, marine life, and coastal processes. In Australia, SST varies seasonally and year-to-year, influenced by phenomena such as **El Niño–Southern Oscillation (ENSO)** and the **Indian Ocean Dipole (IOD)**.  

This project analyzes **monthly SST data (1995–2025)** and uncovers dominant temperature modes using **PCA**, providing insights into seasonal cycles and long-term changes.  

---

## 🎯 Objectives
- Map SST across Australian waters and nearby seas.  
- Create **animations showing monthly SST changes** over 30 years.  
- Use **PCA** to identify key patterns of SST variability.  
- Understand ocean warming trends and regional climate dynamics.  

---

## 🧰 Methodology
1. **Data Processing**  
   - Convert monthly SST data into **standardized anomalies**.  
   - Arrange data: **rows = months**, **columns = locations**.  

2. **Principal Component Analysis (PCA)**  
   - Extract **dominant modes of variability**:  
     - **EOF1**: Spatial contributions of SST variability.  
     - **PC1**: Time series of dominant SST changes.  

3. **Visualization**  
   - Animated maps of monthly SST changes.  
   - Spatial maps (EOF1) showing key regional contributions.  
   - Time series plots (PC1) highlighting trends and seasonal cycles.  

---

## 📊 Results

### SST Animation
![SST Animation](3-Output/sst_1995_2025.gif)

### Dominant Mode of SST Variability
- **EOF1 Spatial Pattern:** Cooler SSTs around southern Australia, warmer SSTs in the north.  
- **PC1 Time Series:**  
  - Clear **annual cycle**: lowest in summer (Feb), highest in winter (Aug).  
  - Explains **≈69% of total SST variability**, showing seasonal cycles dominate.  

![EOF1 Spatial Map Placeholder](https://via.placeholder.com/600x400.png?text=EOF1+Map)  
![PC1 Time Series Placeholder](https://via.placeholder.com/600x400.png?text=PC1+Time+Series)

**Insights:**  
- Positive PC1 → warmer northern waters, cooler southern waters.  
- Seasonal dynamics are the main driver of SST variability around Australia.  
- Foundation for studying **long-term trends and climate impacts**.  

---

## 💻 Usage
Clone the repository and run the scripts to:  
- Generate SST animations.  
- Compute PCA for SST datasets.  
- Reproduce figures and visualizations.  

```bash
git clone https://github.com/yourusername/aus-sst-analysis.git
cd aus-sst-analysis
# Follow instructions in scripts/ folder to run analysis
