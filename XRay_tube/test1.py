# -*- coding: utf-8 -*-
"""
Created on Fri Feb 12 12:48:21 2021

@author: MedPhys
"""

import spekpy as sp
import matplotlib.pyplot as plt
import numpy

s = sp.Spek(kvp=125,th=14,targ='W') # Generate a spectrum (80 kV, 14 degree tube angle)
s.filter('Al', 2.7) # Filter by 4 mm of Al
s.filter('Ti', 0.89) # Filter by 4 mm of Al

hvl = s.get_hvl1() # Get the 1st HVL in mm Al

print(hvl) # Print out the HVL value (Python3 syntax)

data = s.get_spectrum(edges=True)

x = data[0];
y = data[1];

plt.plot(x,y)

# data_write =str(l).strip('[]')

spek_name = 'spekpy_spectrum3.txt' # Specify file name
s.export_spectrum(spek_name, comment='A demo spectrum export') # Export spectrum to file