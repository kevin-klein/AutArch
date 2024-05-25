class MapsController < AuthorizedController
  def index
    @skeleton_angles = Site.includes(
      graves: [:spines, :arrow]
    ).all.to_a.map do |site|
      spines = site.graves.flat_map do |grave|
        grave.spines
      end

      angles = Stats.spine_angles(spines)
      (0..360).step(30).each do |angle|
        angles[angle] ||= 0
      end

      {
        site: site,
        angles:
      }
    end.filter do |grave_data|
      grave_data[:angles].values.sum > 0
    end
  end
end
