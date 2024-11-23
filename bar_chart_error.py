import matplotlib.pyplot as plt
import numpy as np
import json
import sys
import pandas as pd
import itertools
import statistics
from matplotlib import cm

with open('errors_comove.json', 'r') as f:
  comove_error = json.load(f)

with open('errors_inkscape.json', 'r') as f:
  inkscape_error = json.load(f)

with open('user_map.json', 'r') as f:
  user_map = json.load(f)

print(inkscape_error.keys())

for user, errors in comove_error.items():
  figure = plt.figure()
  ax = figure.subplots()
  ax.bar([str(i + 1) for i in range(0, len(errors))], errors)

  ax.set_ylabel('average error')
  ax.set_xlabel('graves')

  username = user_map[user.replace('.csv', '')]

  ax.set_title(f'AutArch error per grave {username}')
  figure.savefig(f"errors_comove_user_{username}.png")

for user, errors in inkscape_error.items():
  figure = plt.figure()
  ax = figure.subplots()
  ax.bar([str(i + 1) for i in range(0, len(errors))], errors)

  ax.set_ylabel('average error')
  ax.set_xlabel('graves')
  username = user_map[user.replace('_inkscape.csv', '')]

  ax.set_title(f'Inkscape error per grave {username}')
  figure.savefig(f"errors_inkscape_user_{username}.png")

# comove_count_data = data.to_dict('list')

# fig, ax = plt.subplots()



# labels = [user_map[user.replace('.csv', '')] for user in data['User']]

# bar_colors = [cm.jet(1.*i/len(labels)) for i in range(0, len(labels))]

# ax.bar([str(i + 1) for i in range(0, len(labels))], data['Error'], label=labels, color=bar_colors)

# ax.set_ylabel('average error')
# ax.set_title('average error per user')
# ax.legend(title='user')

# plt.savefig('bar_chart_error.png')
