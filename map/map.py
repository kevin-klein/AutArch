# !/bin/python3

import pandas as pd
import matplotlib.pyplot as pl
from mpl_toolkits.basemap import Basemap
from adjustText import adjust_text


pl.figure(figsize = (16, 8))

m = Basemap(
	projection='cyl',
	resolution='h',
	llcrnrlon=3,
	llcrnrlat=40,
	urcrnrlon=20,
	urcrnrlat=60
)
m.shadedrelief(alpha=0.6)
m.drawrivers(color='lightsteelblue', zorder=1)

text = []

VLINEVES = {
	'lat': 50.3662076,
	'lon': 14.4423071,
	'name': 'Vlineves'
}

VILKLETICE = {
	'lat': 50.3500781,
	'lon': 13.3821394,
	'name': 'Vikletice'
}

LAUDA = {
	'lat': 49.56596105031933,
	'lon': 9.70325636085325,
	'name': 'Lauda-Königshofen, Taubertal'
}

MONDELANGE = {
	'lat': 49.262778,
	'lon': 6.168611,
	'name': 'Mondelange'
}

for place in [VILKLETICE, VLINEVES, MONDELANGE, LAUDA]:
	pl.scatter(place['lon'], place['lat'], color='r', marker='.', s=10)
	text.append(pl.text(place['lon'], place['lat'], place['name'], fontweight='demibold',color='k', fontsize=8, alpha=0.7))

adjust_text(text, force_text=0.2, arrowprops=dict(arrowstyle='-', alpha=0.8, color='k'))
pl.savefig('comove_map.png', dpi=300, bbox_inches='tight')
