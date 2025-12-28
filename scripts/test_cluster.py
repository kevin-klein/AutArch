from sklearn.decomposition import PCA
from sklearn.cluster import KMeans
import numpy as np

def cluster_poses_with_pca(poses, n_components=2, n_clusters=3):
    """
    Cluster poses using PCA for dimensionality reduction
    """
    # Convert poses to feature vectors (flatten coordinates)
    X = np.array([pose.flatten() for pose in poses])

    # Apply PCA
    pca = PCA(n_components=n_components)
    X_pca = pca.fit_transform(X)

    # Cluster in reduced space
    kmeans = KMeans(n_clusters=n_clusters, random_state=42)
    labels = kmeans.fit_predict(X_pca)

    return labels, pca

# Example usage
poses = [np.array([[0,0], [1,0], [0,1], [1,1]]),
         np.array([[0,0], [-1,0], [0,-1], [-1,-1]])]  # Your list of pose keypoints
labels, pca = cluster_poses_with_pca(poses)

# Visualize explained variance
import matplotlib.pyplot as plt
plt.plot(np.cumsum(pca.explained_variance_ratio_))
plt.xlabel('Number of Components')
plt.ylabel('Cumulative Explained Variance')
plt.title('PCA Explained Variance')
plt.show()


