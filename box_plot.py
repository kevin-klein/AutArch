# Import libraries
import matplotlib.pyplot as plt
import numpy as np
import json
import sys

with open('errors_comove.json', 'r') as f:
  comove_error = json.load(f)

with open('errors_inkscape.json', 'r') as f:
  inkscape_error = json.load(f)

with open('user_map.json', 'r') as f:
  user_map = json.load(f)

data = sorted((comove_error | inkscape_error).items(), reverse=True)

def new_label(label):
  if 'inkscape' in label:
    label = label.replace('_inkscape', '')
    return f'{user_map[label]} IS'
  else:
    return f'{user_map[label]} CO'

keys = [new_label(item[0].replace('.csv', '')) for item in data]
values = [item[1] for item in data]

# Creating dataset
np.random.seed(10)

fig = plt.figure(figsize =(10, 7))
ax = fig.add_subplot(111)

# Creating axes instance
bp = ax.boxplot(values,
                vert = 0)

# x-axis labels
ax.set_yticklabels(keys)

# Removing top axes and right axes
# ticks
ax.get_xaxis().tick_bottom()
ax.get_yaxis().tick_left()

# show plot
plt.savefig('box_errors.png')
