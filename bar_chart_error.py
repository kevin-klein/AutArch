import matplotlib.pyplot as plt
import numpy as np
import json
import sys
import pandas as pd
import itertools
import statistics
from matplotlib import cm

data = pd.read_csv('comove_error.csv')
comove_count_data = data.to_dict('list')

fig, ax = plt.subplots()

with open('user_map.json', 'r') as f:
  user_map = json.load(f)

labels = [user_map[user.replace('.csv', '')] for user in data['User']]

bar_colors = [cm.jet(1.*i/len(labels)) for i in range(0, len(labels))]

ax.bar([str(i + 1) for i in range(0, len(labels))], data['Error'], label=labels, color=bar_colors)

ax.set_ylabel('average error')
ax.set_title('average error per user')
ax.legend(title='user')

plt.savefig('bar_chart_error.png')
