# Premium Fuel Demand & Sales Trend Analysis

This project focuses on analyzing sales data for a fuel retail network. The primary objective is to evaluate the demand for **Premium Fuel** compared to standard fuel, identify high-potential segments, and measure the impact of a specific marketing campaign or time period (July-August 2024) on sales performance.

final REPORT - **https://drive.google.com/drive/u/0/folders/1cdoXZ6oY0TUB0Npi_fypPYCAxM_WVDcb**

## 📂 Project Overview

The analysis is performed primarily in **SQL** (T-SQL/MSSQL) for data manipulation and metric calculation, with **Python** intended for further data visualization.

### Key Goals:
1.  **Segmentation Analysis:** Understand where premium fuel is sold most effectively (by Region, Location type, Gas Station ID, Loyalty Card range).
2.  **Demand Gap Analysis:** Calculate the difference between actual premium orders and "hypothetical" expected orders based on network averages.
3.  **Trend & Impact Analysis:** Compare sales trends **Before**, **During**, and **After** a specific event window to measure "Lift" (incremental sales).

## 🛠 Technologies

* **SQL (T-SQL):** Core logic, ETL, Window Functions, Views, and Aggregations.
* **Python:** Data visualization and statistical modeling (Libraries: `pandas`, `numpy`, `matplotlib`, `seaborn`).

## 📊 Methodology

### 1. Data Preparation & Cleaning
The raw data is merged from `orders`, `azsloc` (locations), and `range` (loyalty cards). The script performs the following cleaning steps:
* Creation of a `merged_table` view for holistic analysis.
* Removal of records with missing critical metadata (Fuel Nomenclature, Placement Type, Region).
* **Feature Engineering:** Creating an `IsPremial` flag (Binary: 1 or 0) based on whether the fuel nomenclature contains the tag `(Преміум)`.

### 2. Market Segmentation
The SQL script calculates the **Premium Ratio** and **Demand Changes** across various dimensions:
* **AZS (Gas Station):** Individual station performance.
* **Location Type:** e.g., Highway vs. City vs. Border Crossing.
* **Region (Oblast):** Geographic performance.
* **Loyalty Card Range:** Customer tiers.
* **Payment Type:** Wallet vs. other methods.

**Key Metric Calculated:**
$$DemandChange = ActualRatio - ExpectedRatio$$

### 3. Temporal Trend Analysis (A/B Testing)
The data is split into three time horizons to measure the "Trend Difference" between Premium and Regular fuel sales:
* **Before:** `< 2024-07-25`
* **During:** `2024-07-25` to `2024-08-06`
* **After:** `> 2024-08-06`

The script calculates the **Trend Difference (TrendBeforeDIFF)**:
> Did the sales volume of Premium fuel grow faster than Regular fuel during the target period?

It also calculates **Additional Sold Liters** attributed to the trend change, excluding specific outliers (e.g., specific regions like Ivano-Frankivsk or Customs transitions).

## 📝 Data Dictionary (Key Columns)

| Column Name (SQL) | Description |
| :--- | :--- |
| `[Номенклатура_пального]` | Fuel Nomenclature (Product Name) |
| `[ВидРозміщення]` | Placement Type (e.g., Highway, City) |
| `[Область]` | Region / District |
| `[Діапазон_карт_лояльності]` | Loyalty Card Range (Customer Tier) |
| `[дата]` | Transaction Date |
| `[літри]` | Volume in Liters |
| `IsPremial` | Computed Flag: 1 if Premium Fuel, 0 if Standard |

## 🚀 How to Run

1.  **Database Setup:** Ensure your MSSQL database contains the source tables `orders`, `azsloc`, and `range`.
2.  **Execute SQL:** Run the provided SQL script. It is structured to:
    * Clean data.
    * Create Views (`orders_before`, `orders_during`, `orders_after`).
    * Output ranked tables showing the segments with the highest positive impact on Premium sales.
3.  **Python Visualization:** Use the exported SQL results with the provided Python imports to generate charts (e.g., bar charts for Segment Ranking or line charts for Trend Analysis).

