# -*- coding: utf-8 -*-
"""
Created on Fri Jun  3 16:26:04 2022

@author: avery
"""

import pandas as pd
import re

############## CREATE DATAFRAME FROM KEYWORDS CSV AND TADD TAGS


df = pd.read_csv(r'C:\Users\avery\Desktop\keywords.csv', dtype = str) #prevents ids from dropping the first set of 0s

df = df.drop('Volume', axis=1)
df = df.drop('Authors (2014:v8n4+, only 1st author surname)', axis=1)
df = df.drop('Reviewed', axis=1)
df = df.fillna('')

keywords_df = df.loc[:, df.columns != 'DHQ ID#']

for i in range(len(keywords_df)):
    for row in keywords_df:
        if keywords_df[row][i] != '':
            keywords_df[row][i] = ('<term corresp="%s"/>' % keywords_df[row][i])
        

for i in range(len(df["DHQ ID#"])):
    if df["DHQ ID#"][i] != '':
        df["DHQ ID#"][i] = ('<keywords corresp="%s.xml">' % df["DHQ ID#"][i])
    

frames = [df["DHQ ID#"], keywords_df]
tagged_df = pd.concat(frames, ignore_index=True, axis=1)
tagged_df = tagged_df.assign(endtag = "</keywords>" )
import numpy as np
np.savetxt('output.xml', tagged_df.values, fmt = "%s")

from bs4 import BeautifulSoup

xml = r'C:\Users\avery\Desktop\taxonomy.xml'
with open(xml, 'r') as tei:
    soup = BeautifulSoup(tei, 'lxml')
    
string_df = tagged_df.to_string()
soup.textclass.replaceWith(string_df)
    
# soup.textclass
    
import xml.etree.ElementTree as ET
tree = ET.parse(r'C:\Users\avery\Desktop\taxonomy.xml')
root = tree.getroot()
