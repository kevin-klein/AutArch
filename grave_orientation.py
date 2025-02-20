import numpy as np
from scipy.cluster.vq import vq, kmeans2, whiten
import matplotlib.pyplot as plt
import json
import math
from sklearn.metrics import silhouette_score
import argparse

if __name__ == '__main__':
  parser = argparse.ArgumentParser()
  parser.add_argument('input')
  parser.add_argument('output')
  args = parser.parse_args()

  with open(args.input, 'r') as f:
    data = json.load(f)

  data =[[math.sin(math.radians(angle)), math.cos(math.radians(angle))] for angle in data]
  data = np.array(data)

  centroids, clusters = kmeans2(data, 2, minit='random')

  w0 = data[clusters == 0]
  w1 = data[clusters == 1]

  plt.plot(w0[:, 0], w0[:, 1], 'o', alpha=0.5, label='cluster 0')
  plt.plot(w1[:, 0], w1[:, 1], 'd', alpha=0.5, label='cluster 1')

  plt.scatter(centroids[:, 0], centroids[:, 1], c='r', zorder=5)

  def positive(angles):
    return (angles + 360) % (360)

  average_w0 = np.average(w0, axis=0)
  average_euclidian_angle_w0 = np.arctan2(average_w0[0], average_w0[1]) * 180 / np.pi

  average_w1 = np.average(w1, axis=0)
  average_euclidian_angle_w1 = np.arctan2(average_w1[0], average_w1[1]) * 180 / np.pi

  print("Averag w0 angle: ", positive(average_euclidian_angle_w0))
  print("Averag w1 angle: ", positive(average_euclidian_angle_w1))

  print("Silhouette score: ", silhouette_score(data, clusters))

  plt.xlim(-1.25, 1.25)
  plt.ylim(-1.25, 1.25)
  ax = plt.gca()
  ax.set_aspect('equal', adjustable='box')
  plt.savefig(args.output, dpi=300)
