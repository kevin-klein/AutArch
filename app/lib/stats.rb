module Stats
  extend self

  def upgma(data)
    scipy.cluster.hierarchy.linkage(data, "average")
  end

  def ward(data)
    scipy.cluster.hierarchy.linkage(data, "ward")
  end

  def mannwhitneyu(x, y)
    scipy.stats.mannwhitneyu(x, y, method: "exact")
  end

  def pca_chart(data)
    colors = numpy.array([
      [209, 41, 41],
      [119, 229, 9],
      [77, 209, 209],
      [115, 10, 219]
    ]) / 255.0
    clusters = []
    data = data.each_with_index do |publication, index|
      publication.each do
        clusters << colors[index]
      end
    end
    # raise
    data = data.flatten(1)

    my_stringIObytes = io.BytesIO.new
    fig, ax = pyplot.subplots
    pyplot.scatter(data.map(&:first), data.map(&:second), c: clusters, cmap: "hsv")
    ax.set_aspect("equal")
    pyplot.ylim(-50, 50)
    pyplot.savefig(my_stringIObytes, format: "jpg", dpi: 300)
    my_stringIObytes.seek(0)
    base64.b64encode(my_stringIObytes.read)
  end

  def base_pca_chart(data)
    my_stringIObytes = io.BytesIO.new
    fig, ax = pyplot.subplots
    pyplot.scatter(data.map(&:first), data.map(&:second), s: data.map { 0.3 })
    ax.set_aspect("equal")
    # pyplot.ylim(-50, 50)
    pyplot.savefig(my_stringIObytes, format: "jpg", dpi: 300)
    my_stringIObytes.seek(0)
    base64.b64encode(my_stringIObytes.read)
  end

  def upgma_figure(linkage)
    fig = pyplot.figure(figsize: [25, 10])
    dn = scipy.cluster.hierarchy.dendrogram(linkage, truncate_mode: "lastp", p: 10, show_leaf_counts: true)

    my_stringIObytes = io.BytesIO.new
    pyplot.savefig(my_stringIObytes, format: "jpg")
    my_stringIObytes.seek(0)
    base64.b64encode(my_stringIObytes.read)
  end

  def cluster_scatter_chart(data, dendro)
    pyplot.figure(figsize: [10, 8])
    clusters = scipy.cluster.hierarchy.fcluster(dendro, t: 10, criterion: "maxclust")

    pca = Pca.new
    pca.fit(data)
    data = pca.transform(data)

    my_stringIObytes = io.BytesIO.new
    pyplot.scatter(data[0..-1, 0], data[0..-1, 1], c: clusters, cmap: "hsv")
    pyplot.savefig(my_stringIObytes, format: "jpg", dpi: 300)
    my_stringIObytes.seek(0)
    base64.b64encode(my_stringIObytes.read)
  end

  def spine_angles(spines)
    spines.map { [_1, _1.grave&.arrow] }
      .filter { |_spine, arrow| arrow.present? }
      .map { |spine, arrow| spine.angle_with_arrow(arrow) }
      .map { round_to_nearest(_1, 30) }
      .tally
  end

  def all_spine_angles(spines)
    spines.map { [_1, _1.grave&.arrow] }
      .filter { |_spine, arrow| arrow.present? }
      .map { |spine, arrow| spine.angle_with_arrow(arrow) }
  end

  def grave_angles(graves)
    graves.map { [_1, _1.arrow] }
      .filter { |_grave, arrow| arrow&.angle.present? }
      .map { |grave, arrow| (grave.angle + arrow.angle) % 180 }
      .map(&:round)
  end

  def graves_pca(publications, special_objects: [], components: 2, excluded: [])
    pca = Pca.new(components: components, scale_data: true)
    fit_pca(pca, publications, excluded: excluded)
    [pca_series(pca, publications, special_objects, excluded: excluded), pca]
  end

  def outlines_efd(publications, excluded: [])
    graves = publications.map do |publication|
      graves = publication.graves.sort_by { _1.id }
      filter_graves(graves, excluded: excluded)
    end.flatten
    return [[], []] if graves.empty?

    contours = graves.map(&:size_normalized_contour)
    frequencies = contours.map { Efd.elliptic_fourier_descriptors(_1, normalize: false, order: 15).to_a.flatten }
    max = (10.0 / frequencies.flatten.max)
    frequencies = frequencies.map { |item| item.each_slice(2).map(&:last).map { _1 * max } }

    [frequencies, graves]
  end

  def efd_pca(frequencies)
    pca = Pca.new(components: 2)
    pca.fit(frequencies)

    pca.transform(frequencies).to_a
  end

  def outlines_pca(publications, special_objects: [], components: 2, excluded: [])
    pca = Pca.new(components: components)

    frequencies, graves = outlines_efd(publications, excluded: excluded)

    return [] if frequencies.empty?

    pca.fit(frequencies)

    pca_data = publications.map do |publication|
      frequencies, graves = outlines_efd([publication])

      if frequencies.empty?
        {
          name: publication.short_description,
          data: []
        }
      else
        grave_data = pca.transform(frequencies).to_a.map do |pca_item|
          convert_pca_item_to_polar(pca_item)
        end

        graves = grave_data.zip(graves)
        data = graves.map do |item, grave|
          item[:mark] = true if special_objects.include?(grave.id)
          item.merge({id: grave.id, title: grave.id})
        end
        {
          name: publication.short_description,
          data: data.map { _1.merge({mark: false}) }
        }
      end
    end

    [pca_data, pca]
  end

  def pca_variance(publications, marked: [], excluded: []) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    return []
    pcas = graves_pca(publications, components: 1, excluded: excluded)[0]

    result = pcas.map do |series|
      mean = pca_mean(series)
      variance = series_variance(series, mean)
      {
        name: series[:name],
        variance: variance
      }
    end

    if marked.empty?
      result
    else
      special = pcas.map { _1[:data] }.flatten.filter { marked.include?(_1[:id]) }
      marked_series = {data: special}
      mean = pca_mean(marked_series)
      marked_items_variance = series_variance(marked_series, mean)

      result + [{
        name: "marked items",
        variance: marked_items_variance
      }]
    end
  end

  def pca_mean(series)
    []
    # series[:data].map { _1[:x] }.sum / series[:data].length
  end

  def series_variance(series, mean)
    return 0
    series[:data].map { |item| (item[:x] - mean)**2 }.sum / series[:data].length
  end

  def pca_series(pca, publications, special_objects, excluded: [])
    publications.map do |publication|
      graves = publication.graves
      graves = filter_graves(graves, excluded: excluded)
      return [] if graves.size <= 1
      grave_data = pca_transform_graves(pca, graves, special_objects)

      {
        name: publication.short_description,
        data: grave_data
      }
    end
  end

  def pca_transform_graves(pca, graves, special_objects)
    grave_data = pca.transform(convert_graves_to_size(graves)).to_a.map do |pca_item|
      convert_pca_item_to_polar(pca_item)
    end
    graves = grave_data.zip(graves)
    graves.map do |data, grave|
      data[:mark] = true if special_objects.include?(grave.id)
      data.merge({id: grave.id, title: grave.id})
    end
  end

  def convert_pca_item_to_polar(pca_item)
    case pca_item.length
    when 1
      {x: pca_item[0]}
    when 2
      {x: pca_item[0], y: pca_item[1]}
    end
  end

  def filter_graves(graves, excluded: [])
    graves.filter do |grave|
      !excluded.include?(grave.id) &&
        # grave.grave_cross_section.normalized_depth_with_unit[:unit] == 'm' &&
        grave.normalized_width_with_unit[:unit] == "m" &&
        grave.normalized_height_with_unit[:unit] == "m" &&
        grave.perimeter_with_unit[:unit] == "m" &&
        grave.area_with_unit[:unit] == "&#13217;" &&
        grave.arrow.present?
    end
  end

  def fit_pca(pca, publications, excluded: [])
    graves = publications.flat_map do |publication|
      graves = publication.figures.filter { _1.is_a?(Grave) }
      graves = filter_graves(graves, excluded: excluded)
      convert_graves_to_size(graves)
    end

    return [] if graves.size <= 1

    pca.fit(graves)
  end

  def convert_graves_to_size(graves)
    graves.map do |grave|
      [
        grave.normalized_width_with_unit[:value],
        grave.normalized_height_with_unit[:value],
        grave.grave_cross_section&.normalized_depth_with_unit.try(:[], :value) || 0,
        ((grave.angle.abs.round + grave.arrow.angle) % 180).round
      ]
    end.compact
  end

  def round_to_nearest(number, increment)
    increment * ((number + (increment / 2.0)).to_i / increment)
  end
end
