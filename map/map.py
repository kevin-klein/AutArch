# !/bin/python3

import pandas as pd
import matplotlib.pyplot as pl
from mpl_toolkits.basemap import Basemap
from adjustText import adjust_text
from matplotlib.patches import Polygon
import geopandas as gpd
from shapely.geometry import box
import matplotlib.pyplot as plt
import contextily as ctx
from xyzservices import TileProvider
from cartopy import crs as ccrs

pl.figure(figsize = (16, 8))

# m = Basemap(
# 	projection='cyl',
# 	resolution='h',
# 	llcrnrlon=3,
# 	urcrnrlon=50,
# 	llcrnrlat=35,
# 	urcrnrlat=65
# )
# m.shadedrelief(alpha=0.6)
# m.drawrivers(color='lightsteelblue', zorder=1)
tile_provider = TileProvider({
    "url": 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Shaded_Relief/MapServer/tile/{z}/{y}/{x}',
    "name": "World_Shaded_Relief",
    "attribution": "Tiles © Esri — Source: Esri",
    "cross_origin": "Anonymous"}
)

bbox = (3, 35, 50, 65)
bbox_polygon = gpd.GeoDataFrame(geometry=[box(*bbox)], crs="EPSG:4326")

# Create a map with PlateCarree projection
fig, ax = plt.subplots(subplot_kw={'projection': ccrs.PlateCarree()})

# Add the bounding box polygon to the map
bbox_polygon.boundary.plot(ax=ax, color='#00000000')

# Add XYZ tiles using contextily and xyzservices.TileProvider
ctx.add_basemap(ax, source=tile_provider, zoom=7, crs="EPSG:4326")

text = []

VLINEVES = {
	'lat': 50.3662076,
	'lon': 14.4423071,
	'name': 'Vlinĕves'
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

Ciulnita = {
	'lat': 44.5373408,
	'lon': 27.3290492,
	'name': 'Ciulniţa'
}

Ploiesti = {
	'lat': 44.9322345,
	'lon': 25.9686931,
	'name': 'Ploiești'
}

Rast = {
	'lat': 43.8871136,
	'lon': 23.2735062,
	'name': 'Rast'
}

Gurbanesti = {
	'lat': 44.3792834,
	'lon': 26.681199,
	'name': 'Gurbănești'
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
	'name': 'Faifert 2014'
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
	'name': 'Ivanova & Toshchev 2015'
}

LOUGAS_2016 = {
	'left_top': {
		'lat': 59.76703651770406,
		'lon': 21.6013758030299
	},
	'right_top': {
		'lat': 59.76703651770406,
		'lon': 27.50023158104496
	},
	'left_bottom': {
		'lat': 57.239364088889104,
		'lon': 21.6013758030299
	},
	'right_bottom': {
		'lat': 57.239364088889104,
		'lon': 27.50023158104496
	},
	'name': 'Lõugas et al. 2016'
}

Gadzyatskaya_1976 = {
	'left_top': {
		'lat': 58.104821370702204,
		'lon': 37.8562392180725
	},
	'right_top': {
		'lat': 58.104821370702204,
		'lon': 47.63966569928308
	},
	'left_bottom': {
		'lat': 54.61221373386977,
		'lon': 37.8562392180725
	},
	'right_bottom': {
		'lat': 54.61221373386977,
		'lon': 47.63966569928308
	},
	'name': 'Gadzyackaya 1976'
}

Krainov_1963 = {
	'left_top': {
		'lat': 56.57242189778502,
		'lon': 36.151626620253325
	},
	'right_top': {
		'lat': 56.57242189778502,
		'lon': 39.11353142737622
	},
	'left_bottom': {
		'lat': 54.36300312740703,
		'lon': 36.151626620253325
	},
	'right_bottom': {
		'lat': 54.36300312740703,
		'lon': 39.11353142737622
	},
	'name': 'Krainov 1963'
}

Krainov_1964 = {
	'left_top': {
		'lat': 57.22313603869134,
		'lon': 37.499534552379245
	},
	'right_top': {
		'lat': 57.22313603869134,
		'lon': 40.43452022589467
	},
	'left_bottom': {
		'lat': 56.17501721104373,
		'lon': 37.499534552379245
	},
	'right_bottom': {
		'lat': 56.17501721104373,
		'lon': 40.43452022589467
	},
	'name': 'Krainov 1964'
}


for place in [
	VILKLETICE,
	VLINEVES,
	MONDELANGE,
	LAUDA,
	SMEENI,
	BLEJOI,
	MOARA_VLASIEI,
	Ciulnita,
	Ploiesti,
	Rast,
	Gurbanesti,
	ARICESTI]:
	pl.scatter(place['lon'], place['lat'], color='r', marker='.', s=10)
	text.append(pl.text(place['lon'], place['lat'], place['name'], fontweight='demibold',color='k', fontsize=6, alpha=0.7))


for rect in [
	EARLY_BRONZE_AGE_RECTANGLE,
	KOSTYLEVA_UTKIN_RECTANGLE,
	IVANOVA_TOSHCHEV,
	LOUGAS_2016,
	Gadzyatskaya_1976,
	Krainov_1963,
	Krainov_1964]:
	poly = Polygon([
		(rect['left_top']['lon'], rect['left_top']['lat']),
		(rect['right_top']['lon'], rect['right_top']['lat']),
		(rect['right_bottom']['lon'], rect['right_bottom']['lat']),
		(rect['left_bottom']['lon'], rect['left_bottom']['lat']),
	], fill=False, edgecolor='red',linewidth=1)
	pl.gca().add_patch(poly)
	text.append(pl.text(rect['left_top']['lon'], rect['left_top']['lat'], rect['name'], fontweight='demibold',color='k', fontsize=6, alpha=0.7))

adjust_text(text, force_text=0.2, arrowprops=dict(arrowstyle='-', alpha=0.8, color='k'))
pl.savefig('comove_map.png', dpi=300, bbox_inches='tight')
