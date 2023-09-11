# !/bin/python3

import pandas as pd
import matplotlib.pyplot as pl
from mpl_toolkits.basemap import Basemap
from adjustText import adjust_text
from matplotlib.patches import Polygon

pl.figure(figsize = (16, 8))

m = Basemap(
	projection='cyl',
	resolution='h',
	llcrnrlon=3,
	urcrnrlon=50,
	llcrnrlat=35,
	urcrnrlat=65
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

SOUTHERN_BUG_RECTANGLE = {
	'left_top': {
		'lat': 47.9747313,
		'lon': 30.8916686
	},
	'right_top': {
		'lat': 47.9747313,
		'lon': 32.4235999
	},
	'left_bottom': {
		'lat': 46.2978464,
		'lon': 30.8916686
	},
	'right_bottom': {
		'lat': 46.2978464,
		'lon': 32.4235999
	},
}
EARLY_BRONZE_AGE_RECTANGLE = {
	'left_top': {
		'lat': 48.5801736,
		'lon': 38.0487133
	},
	'right_top': {
		'lat': 48.5801736,
		'lon': 44.006422
	},
	'left_bottom': {
		'lat': 45.994140,
		'lon': 38.0487133
	},
	'right_bottom': {
		'lat': 45.994140,
		'lon': 44.006422
	},
}

for place in [VILKLETICE, VLINEVES, MONDELANGE, LAUDA]:
	pl.scatter(place['lon'], place['lat'], color='r', marker='.', s=10)
	text.append(pl.text(place['lon'], place['lat'], place['name'], fontweight='demibold',color='k', fontsize=8, alpha=0.7))

poly = Polygon([
	(SOUTHERN_BUG_RECTANGLE['left_top']['lon'], SOUTHERN_BUG_RECTANGLE['left_top']['lat']),
	(SOUTHERN_BUG_RECTANGLE['right_top']['lon'], SOUTHERN_BUG_RECTANGLE['right_top']['lat']),
	(SOUTHERN_BUG_RECTANGLE['right_bottom']['lon'], SOUTHERN_BUG_RECTANGLE['right_bottom']['lat']),
	(SOUTHERN_BUG_RECTANGLE['left_bottom']['lon'], SOUTHERN_BUG_RECTANGLE['left_bottom']['lat']),
], fill=False, edgecolor='red',linewidth=1)
pl.gca().add_patch(poly)
text.append(pl.text(SOUTHERN_BUG_RECTANGLE['left_top']['lon'], SOUTHERN_BUG_RECTANGLE['left_top']['lat'], 'Shaposhnikova et al. 1986', fontweight='demibold',color='k', fontsize=8, alpha=0.7))

poly = Polygon([
	(EARLY_BRONZE_AGE_RECTANGLE['left_top']['lon'], EARLY_BRONZE_AGE_RECTANGLE['left_top']['lat']),
	(EARLY_BRONZE_AGE_RECTANGLE['right_top']['lon'], EARLY_BRONZE_AGE_RECTANGLE['right_top']['lat']),
	(EARLY_BRONZE_AGE_RECTANGLE['right_bottom']['lon'], EARLY_BRONZE_AGE_RECTANGLE['right_bottom']['lat']),
	(EARLY_BRONZE_AGE_RECTANGLE['left_bottom']['lon'], EARLY_BRONZE_AGE_RECTANGLE['left_bottom']['lat']),
], fill=False, edgecolor='red',linewidth=1)
pl.gca().add_patch(poly)
text.append(pl.text(EARLY_BRONZE_AGE_RECTANGLE['left_top']['lon'], EARLY_BRONZE_AGE_RECTANGLE['left_top']['lat'], 'Fajfert 2014', fontweight='demibold',color='k', fontsize=8, alpha=0.7))

adjust_text(text, force_text=0.2, arrowprops=dict(arrowstyle='-', alpha=0.8, color='k'))
pl.savefig('comove_map.png', dpi=300, bbox_inches='tight')
