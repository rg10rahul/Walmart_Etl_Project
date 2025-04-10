# Walmart_Data_Etl_Project

This project demonstrates a complete ETL (Extract, Transform, Load) pipeline built using Python and MySQL for analyzing Walmart sales data.
The project fetches data from Kaggle using API, processes it using Pandas, and loads it into a MySQL database for further analysis.

## Project Workflow : 

### Extract:
* Walmart dataset is downloaded from Kaggle using the Kaggle API.
* Authentication is handled via kaggle.json.

### Transform:
Raw data is cleaned and transformed using Pandas:
* Missing values handled
* Data types normalized
* New columns derived for analysis

### Load:
* Transformed data is loaded into a MySQL database using Sqlalchemy
* Tables are structured for efficient querying and analysis.
