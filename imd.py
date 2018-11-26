#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
    Retrieving the position of bookmakers across the UK from OpenStreeMap. The position is given in terms of longitudes and lattitude
"""

import pandas as pd
import requests


overpass_url = "http://overpass-api.de/api/interpreter"
overpass_query = """
[out:json];
area["ISO3166-1"="GB"][admin_level=2];
(node["shop"="bookmaker"](area);
 way["shop"="bookmaker"](area);
 rel["shop"="bookmaker"](area);
);
out center;
"""
response = requests.get(overpass_url, 
                        params={'data': overpass_query})
geojson = response.json()


lattitudes = [position['lat'] for position in geojson['elements']]
longitudes = [position['lon'] for position in geojson['elements']]

positions = pd.DataFrame({'lat': lattitudes, 'lon' : longitudes})
positions.to_csv('bookmaker_positions.csv')