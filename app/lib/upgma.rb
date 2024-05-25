module Upgma
  extend self
  # unweighted pair group method with arithmetic mean

  def cluster(clusters, k)
    clusters = clusters.clone
    matrix = build_matrix(clusters)
    cluster_index_map = []
    groups = []

    while clusters.length > k
      lowest_distance = min_index(matrix)
      row = lowest_distance[:row]
      col = lowest_distance[:col]

      cluster1 = clusters[row]
      cluster2 = clusters[col]

      if row > col
        clusters.delete_at(row)
        clusters.delete_at(col)
      else
        clusters.delete_at(col)
        clusters.delete_at(row)
      end
      groups.append([row, col])

      clusters.append(cluster1 + cluster2)
      matrix = build_matrix(clusters)
    end

    clusters
    # groups
  end

  def build_tree(groups)
    groups.each do |pair|
    end
  end

  def min_index(matrix)
    min_row = Float::INFINITY
    min_col = Float::INFINITY
    min_value = Float::INFINITY
    matrix.each_with_index do |value, row, col|
      if value < min_value
        min_value = value
        min_row = row
        min_col = col
      end
    end

    {row: min_row, col: min_col}
  end

  def average_distance(cluster1, cluster2)
    cluster1.map do |item1|
      cluster2.map do |item2|
        data1 = {x: item1[0], y: item1[1]}
        data2 = {x: item2[0], y: item2[1]}
        Distance.point_distance(data1, data2)
      end.sum
    end.sum / (cluster1.length * cluster2.length)
  end

  def build_matrix(clusters)
    data = clusters.map.with_index do |cluster1, index1|
      clusters.map.with_index do |cluster2, index2|
        if index1 == index2
          Float::INFINITY
        else
          average_distance(cluster1, cluster2)
        end
      end
    end
    Matrix.rows(data)
  end
end
