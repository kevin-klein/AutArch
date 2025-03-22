namespace :features do
  task update: :environment do
    Figure.where(type: ["Ceramic", "StoneTool", "Artefact", "ShaftAxe"]).where.not(parent_id: nil).find_each do |ceramic|
      ObjectFeatures.run(ceramic)

      next if ceramic.contour.empty?

      frequencies = Efd.elliptic_fourier_descriptors(ceramic.contour, normalize: true, order: 15).to_a.flatten
      max = (10.0 / frequencies.flatten.max)
      frequencies = frequencies.each_slice(2).map(&:last).map { _1 * max }
      ceramic.efds = frequencies
      ceramic.save!
    end
  end

  task build_matrix: :environment do
    ObjectSimilarity.transaction do
      ObjectSimilarity.delete_all

      Figure.where(type: ["Ceramic", "StoneTool", "Artefact", "ShaftAxe"]).where.not(parent_id: nil).find_each do |ceramic|
        Figure.where(type: ["Ceramic", "StoneTool", "Artefact", "ShaftAxe"]).where.not(parent_id: nil).find_each do |compare_to|
          next if ceramic.features.empty?
          next if compare_to.features.empty?
          next if ceramic.efds.empty?
          next if compare_to.efds.empty?

          FeatureSimilarity.create!(
            first: ceramic,
            second: compare_to,
            similarity: CosineSimilarity.similarity(ceramic.features, compare_to.features)
          )

          EfdSimilarity.create!(
            first: ceramic,
            second: compare_to,
            similarity: CosineSimilarity.similarity(ceramic.efds, compare_to.efds)
          )
        end
      end
    end
  end
end
