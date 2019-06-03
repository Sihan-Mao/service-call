# Beijing City Service Call Shiny Dashboard

## About Dataset

This tutorial introduces spaciotemporal data analysis of Beijing City Service Call data, "*12345*".

Beijing 12345 Call is a non-emergency city services request and information inquiry service provided the City of Beijing.

The call dataset studied in this project is the 12345 data recorded from March 2017 to May 2018 in 2 large residential areas in the northern suburb of Beijing. The 2 large residential areas, Hui Long Guan and Tian Tong Yuan, consist of 7 neighborhoods and 132 communities.

The datasets used for the analysis are listed below,

| Dataset | Format | Content |
|---|---|---|
| **callvillage** | csv | Service type; Timestamp; Location |
| **village** | shp | Communities Polygons | 
| **town** | shp | Neighborhoods Polygons | 

## Shiny Dashboard

The Dashboard is created for the purpose of visualizing 1) temporal changes of total call numbers in different time span (**Day, Week, Month**)
