module Stats
  extend self

  def spine_angles(spines)
    spines.map { [_1, _1.grave.arrow] }
          .map { |spine, arrow| spine.angle_with_arrow(arrow) }
          .map { round_to_nearest(_1, 30) }
          .tally
  end

  def grave_angles(graves)
    graves.map { [_1, _1.arrow] }
          .map { |grave, arrow| (grave.angle + arrow.angle) % 180 }
          .map(&:round)
  end

  def graves_pca(*publications, special_objects: [])
    pca = PCA.new(components: 2, scale_data: true)
    fit_pca(pca, publications)
    [pca_series(pca, publications, special_objects), pca]
  end

  private

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

  def pca_transform_graves(pca, graves, special_objects) # rubocop:disable Metrics/MethodLength
    grave_data = pca.fit_transform(convert_graves_to_size(graves)).to_a.map do |x, y|
      {
        x: x,
        y: y
      }
    end
    graves = grave_data.zip(graves)
    graves.map do |data, grave|
      data[:mark] = true if special_objects.include?(grave.id)
      data.merge({ id: grave.id, title: grave.id })
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
