# Import libraries
import matplotlib.pyplot as plt
import numpy as np
import json
import sys

data = json.load(open(sys.argv[1]))

keys = data.keys()
values = data.values()

# Creating dataset
np.random.seed(10)
data = values

fig = plt.figure(figsize =(10, 7))
ax = fig.add_subplot(111)

# Creating axes instance
bp = ax.boxplot(data,
                vert = 0)

# x-axis labels
ax.set_yticklabels(keys)

# Removing top axes and right axes
# ticks
ax.get_xaxis().tick_bottom()
ax.get_yaxis().tick_left()

# show plot
plt.savefig(sys.argv[2])
