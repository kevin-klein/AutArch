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

  def graves_pca(publications, special_objects: [], components: 2)
    pca = PCA.new(components: components, scale_data: true)
    fit_pca(pca, publications)
    [pca_series(pca, publications, special_objects), pca]
  end

  def pca_variance(publications)
    graves_pca(publications, components: 1)[0].map do |series|
      mean = pca_mean(series)
      variance = series_variance(series, mean)
      {
        name: series[:name],
        variance: variance
      }
    end
  end

  private

  def pca_mean(series)
    series[:data].map { _1[:x] }.sum / series[:data].length
  end

  def series_variance(series, mean)
    series[:data].map { |item| (item[:x] - mean)**2 }.sum / series[:data].length
  end

  def pca_series(pca, publications, special_objects)
    publications.map do |publication|
      graves = publication.graves
      grave_data = pca_transform_graves(pca, graves, special_objects)

      {
        name: publication.short_description,
        data: grave_data
      }
    end
  end

  def pca_transform_graves(pca, graves, special_objects)
    grave_data = pca.fit_transform(convert_graves_to_size(graves)).to_a.map do |pca_item|
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

  def fit_pca(pca, publications)
    publications.each do |publication|
      graves = publication.figures.filter { _1.is_a?(Grave) }
      graves = convert_graves_to_size(graves)
      pca.fit(graves)
    end
  end

  def convert_graves_to_size(graves)
    graves.map do |grave|
      next if grave.grave_cross_section.nil?

      [
        grave.width_with_unit[:value],
        grave.height_with_unit[:value],
        grave.perimeter_with_unit[:value],
        grave.area_with_unit[:value],
        grave.grave_cross_section.height_with_unit[:value]
      ]
    end.compact
  end

  def round_to_nearest(number, increment)
    increment * ((number + (increment / 2.0)).to_i / increment)
  end
end
