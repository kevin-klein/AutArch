# Import libraries
import matplotlib.pyplot as plt
import numpy as np
import json
import sys
import pandas as pd
import itertools
import statistics

avg = lambda data: float(sum(data)) / len(data)

data = pd.read_csv('comove_count.csv')
comove_count_data = data.to_dict('list')

data = pd.read_csv('inkscape_count.csv')
inkscape_count_data = data.to_dict('list')

with open('errors_comove.json', 'r') as f:
  comove_error = json.load(f)

with open('errors_inkscape.json', 'r') as f:
  inkscape_error = json.load(f)

with open('user_map.json', 'r') as f:
  user_map = json.load(f)

# data = sorted((comove_error | inkscape_error).items(), reverse=True)

# def new_label(label):
#   if 'inkscape' in label:
#     label = label.replace('_inkscape', '')
#     return f'{user_map[label]} IS'
#   else:
#     return f'{user_map[label]} CO'


# keys = [new_label(item[0].replace('.csv', '')) for item in data]
# values = [item[1] for item in data]

data = itertools.zip_longest(*comove_error.values())
data = [[value for value in item if value is not None] for item in data]

avg_comove_data = [avg(item) * 100 for item in data]

data = itertools.zip_longest(*inkscape_error.values())
data = [[value for value in item if value is not None] for item in data]

avg_inkscape_data = [avg(item) * 100 for item in data]
# Creating dataset
np.random.seed(10)

fig = plt.figure(figsize =(10, 7))

fig, (ax1, ax2) = plt.subplots(1, 2)

# Creating axes instance
bp = ax1.boxplot([avg_inkscape_data, avg_comove_data], vert = True)
ax1.set_title('Average Error (in %)')

# x-axis labels
ax1.set_xticklabels(['Inkscape', 'CoMove'])

# Removing top axes and right axes
# ticks
ax1.get_xaxis().tick_bottom()
ax1.get_yaxis().tick_left()
ax1.set_ylim(0)

ax2.set_title('Average Processed Graves')
ax2.bar(['Inkscape', 'CoMove'], [statistics.mean(inkscape_count_data['Graves']), statistics.mean(comove_count_data['Graves'])])

plt.savefig('box_errors.png')
