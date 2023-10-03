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
	'name': 'Lauda-Königshofen'
}

MONDELANGE = {
	'lat': 49.262778,
	'lon': 6.168611,
	'name': 'Mondelange'
}

SMEENI = {
	'lat': 44.9975659,
	'lon': 26.848526,
	'name': 'Smeeni'
}

MANESTI = {
	'lat': 44.8696819,
	'lon': 25.8264969,
	'name': 'Manesti'
}

BLEJOI = {
	'lat': 44.9742437,
	'lon': 25.9483646,
	'name': 'Blejoi'
}

MOARA_VLASIEI = {
	'lat': 44.641288,
	'lon': 26.196292,
	'name': 'Moara Vlasiei'
}

ARICESTI = {
	'lat': 44.9500142,
	'lon': 25.8230333,
	'name': 'Ariceștii Rahtivani'
}

KOSTYLEVA_UTKIN_RECTANGLE = {
	'left_bottom': {
		'lat': 58.27543554276217,
		'lon': 42.259576703515066
	},
	'right_bottom': {
		'lat': 55.03183134970524,
		'lon': 42.259576703515066
	},
	'left_top': {
		'lat': 58.27543554276217,
		'lon': 36.372101064012206,
	},
	'right_top': {
		'lat': 55.03183134970524,
		'lon': 36.372101064012206
	},
	'name': 'Kostyleva & Utkin 2010'
}

FRINCULEASA_CHILDREN_OF_THE_STEPPE_RECTANGLE = {
	'left_bottom': {
		'lat' :44.846219,
		'lon': 25.808062
	},
	'right_bottom': {
		'lat' :44.846219,
		'lon': 26.092226
	},
	'left_top': {
		'lat' :45.090368,
		'lon': 25.808062
	},
	'right_top': {
		'lat' :45.090368,
		'lon': 26.092226
	},
	'name': 'Frînculeasa (2019, 2013, 2014, 2015)'
}

FRINCULEASA_2017_RECTANGLE = {
	'right_bottom': {
		'lat': 44.077390,
		'lon': 26.013624
	},
	'left_top': {
		'lat': 43.913002,
		'lon': 25.559257
	},
	'left_bottom': {
		'lat': 43.913002,
		'lon': 25.165311
	},
	'right_top': {
		'lat': 44.077390,
		'lon': 25.559257
	},
	'name': 'Frînculeasa 2017'
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
	'name': 'Shaposhnikova et al. 1986'
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
	'name': 'Fajfert 2014'
}

IVANOVA_TOSHCHEV = {
	'left_top': {
		'lat': 44.52484591189992,
		'lon': 40.150610326040905
	},
	'right_top': {
		'lat': 48.355084787446785,
		'lon': 40.150610326040905
	},
	'left_bottom': {
		'lat': 44.52484591189992,
		'lon': 27.93866803511914
	},
	'right_bottom': {
		'lat': 48.355084787446785,
		'lon': 27.93866803511914
	},
	'name': 'Ivanova & Toshchev'
}

for place in [
	VILKLETICE,
	VLINEVES,
	MONDELANGE,
	LAUDA,
	SMEENI,
	BLEJOI,
	MOARA_VLASIEI,
	ARICESTI]:
	pl.scatter(place['lon'], place['lat'], color='r', marker='.', s=10)
	text.append(pl.text(place['lon'], place['lat'], place['name'], fontweight='demibold',color='k', fontsize=8, alpha=0.7))


for rect in [
	SOUTHERN_BUG_RECTANGLE,
	EARLY_BRONZE_AGE_RECTANGLE,
	FRINCULEASA_2017_RECTANGLE,
	KOSTYLEVA_UTKIN_RECTANGLE,
	IVANOVA_TOSHCHEV,
	FRINCULEASA_CHILDREN_OF_THE_STEPPE_RECTANGLE]:
	poly = Polygon([
		(rect['left_top']['lon'], rect['left_top']['lat']),
		(rect['right_top']['lon'], rect['right_top']['lat']),
		(rect['right_bottom']['lon'], rect['right_bottom']['lat']),
		(rect['left_bottom']['lon'], rect['left_bottom']['lat']),
	], fill=False, edgecolor='red',linewidth=1)
	pl.gca().add_patch(poly)
	text.append(pl.text(rect['left_top']['lon'], rect['left_top']['lat'], rect['name'], fontweight='demibold',color='k', fontsize=8, alpha=0.7))

adjust_text(text, force_text=0.2, arrowprops=dict(arrowstyle='-', alpha=0.8, color='k'))
pl.savefig('comove_map.png', dpi=300, bbox_inches='tight')
