import matplotlib.pyplot as plt
import numpy as np
import json
import sys
import pandas as pd
import itertools
import statistics
from matplotlib import cm

autarch_data = pd.read_csv('comove_count.csv')
inkscape_data = pd.read_csv('inkscape_count.csv')

fig, ax = plt.subplots()

with open('user_map.json', 'r') as f:
  user_map = json.load(f)

count_data = {
  'Autarch': [],
  'Inkscape': []
}

for user in user_map:
  inkscape_count = inkscape_data.loc[inkscape_data['User'] == f"{user}_inkscape.csv"]
  if len(inkscape_count.to_dict(orient='records')) > 0:
    inkscape_count = inkscape_count['Graves'].values[0]
  else:
    inkscape_count = np.nan

  autarch_count = autarch_data.loc[autarch_data['User'] == f"{user}.csv"]
  if len(autarch_count.to_dict(orient='records')) > 0:
    autarch_count = autarch_count['Graves'].values[0]
  else:
    autarch_count = np.nan

  count_data['Autarch'] = count_data['Autarch'] + [autarch_count]
  count_data['Inkscape'] = count_data['Inkscape'] + [inkscape_count]

x = np.arange(len(user_map.keys()))  # the label locations
width = 0.3  # the width of the bars
multiplier = 0

fig, ax = plt.subplots(layout='constrained')

# print(count_data)

for attribute, measurement in count_data.items():
    offset = width * multiplier
    rects = ax.bar(x + offset, measurement, width, label=attribute)
    ax.bar_label(rects, padding=3)
    multiplier += 1

# Add some text for labels, title and custom x-axis tick labels, etc.
ax.set_ylabel('number of processed graves')
ax.set_title('Processed graves by user')
ax.set_xticks(x + width, user_map.values())
ax.legend(loc='upper left', ncols=3)

plt.savefig('bar_chart_count.png', dpi=300)
