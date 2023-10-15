module Stats
  extend self

  def spine_angles(spines)
    spines.map { [_1, _1.grave&.arrow] }
          .filter { |_spine, arrow| arrow.present? }
          .map { |spine, arrow| spine.angle_with_arrow(arrow) }
          .map { round_to_nearest(_1, 30) }
          .tally
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

  def outlines_pca(publications, special_objects: [], components: 2, excluded: [])
    pca = Pca.new(components: components, scale_data: true)

    graves = publications.map do |publication|
      graves = publication.graves.sort_by { _1.id }
      filter_graves(graves, excluded: excluded)
    end.flatten

    contours = graves.map(&:contour)
    frequencies = contours.map { Efd.elliptic_fourier_descriptors(_1, normalize: true, order: 8).to_a.flatten }
    pca.fit(frequencies)

    pca_data = publications.map do |publication|
      graves = publication.graves.sort_by { _1.id }
      graves = filter_graves(graves, excluded: excluded)

      contours = graves.map(&:contour)
      frequencies = contours.map { Efd.elliptic_fourier_descriptors(_1, normalize: true, order: 8).to_a.flatten }
      data = pca.transform(frequencies).to_a.map do |pca_item|
        convert_pca_item_to_polar(pca_item)
      end
      graves = data.zip(graves)
      data = graves.map do |item, grave|
        item[:mark] = true if special_objects.include?(grave.id)
        item.merge({ id: grave.id, title: grave.id })
      end
      {
        name: publication.short_description,
        data: data.map { _1.merge({ mark: false }) }
      }
    end.flatten

    [pca_data, pca]
  end

  def pca_variance(publications, marked: [], excluded: []) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
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
      marked_series = { data: special }
      mean = pca_mean(marked_series)
      marked_items_variance = series_variance(marked_series, mean)

      result + [{
        name: 'marked items',
        variance: marked_items_variance
      }]
    end
  end

  private

  def pca_mean(series)
    series[:data].map { _1[:x] }.sum / series[:data].length
  end

  def series_variance(series, mean)
    series[:data].map { |item| (item[:x] - mean)**2 }.sum / series[:data].length
  end

  def pca_series(pca, publications, special_objects, excluded: [])
    publications.map do |publication|
      graves = publication.graves
      graves = filter_graves(graves, excluded: excluded)
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
      data.merge({ id: grave.id, title: grave.id })
    end
  end

  def convert_pca_item_to_polar(pca_item)
    case pca_item.length
    when 1
      { x: pca_item[0] }
    when 2
      { x: pca_item[0], y: pca_item[1] }
    end
  end

  def filter_graves(graves, excluded: [])
    graves.filter do |grave|
      (
        !excluded.include?(grave.id) &&
        grave.grave_cross_section.present? &&
        grave.grave_cross_section.normalized_depth_with_unit[:unit] == 'm' &&
        grave.normalized_width_with_unit[:unit] == 'm' &&
        grave.normalized_height_with_unit[:unit] == 'm' &&
        grave.perimeter_with_unit[:unit] == 'm' &&
        grave.area_with_unit[:unit] == '&#13217;' &&
        grave.arrow.present?
      )
    end
  end

  def fit_pca(pca, publications, excluded: [])
    graves = publications.map do |publication|
      graves = publication.figures.filter { _1.is_a?(Grave) }
      graves = filter_graves(graves, excluded: excluded)
      convert_graves_to_size(graves)
    end.flatten(1)

    pca.fit(graves)
  end

  def convert_graves_to_size(graves)
    graves.map do |grave|
      [
        grave.normalized_width_with_unit[:value],
        grave.normalized_height_with_unit[:value],
        grave.grave_cross_section.normalized_depth_with_unit[:value],
        ((grave.angle.abs.round + grave.arrow.angle) % 180).round
      ]
    end.compact
  end

  def round_to_nearest(number, increment)
    increment * ((number + (increment / 2.0)).to_i / increment)
  end
end
