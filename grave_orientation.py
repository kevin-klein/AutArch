import numpy as np
from scipy.cluster.vq import vq, kmeans2, whiten
import matplotlib.pyplot as plt
import json
import math
from sklearn.metrics import silhouette_score, davies_bouldin_score, calinski_harabasz_score
import sys

with open(sys.argv[1], 'r') as f:
  data = json.load(f)

data =[[math.sin(math.radians(angle)), math.cos(math.radians(angle))] for angle in data]
data = np.array(data)
# data = whiten(data)

centroids, clusters = kmeans2(data, 2, minit='random')

w0 = data[clusters == 0]
w1 = data[clusters == 1]

plt.plot(w0[:, 0], w0[:, 1], 'o', alpha=0.5, label='cluster 0')
plt.plot(w1[:, 0], w1[:, 1], 'd', alpha=0.5, label='cluster 1')

def positive(angles):
  return (angles + 360) % (360)

average_w0 = np.average(w0, axis=0)
average_euclidian_angle_w0 = np.arctan2(average_w0[0], average_w0[1]) * 180 / np.pi

average_w1 = np.average(w1, axis=0)
average_euclidian_angle_w1 = np.arctan2(average_w1[0], average_w1[1]) * 180 / np.pi

print(positive(average_euclidian_angle_w0))
print(positive(average_euclidian_angle_w1))

print(silhouette_score(data, clusters))

plt.scatter(centroids[:, 0], centroids[:, 1], c='r')
ax = plt.gca()
ax.set_aspect('equal', adjustable='box')
plt.savefig('grave orientation cluster.png')
