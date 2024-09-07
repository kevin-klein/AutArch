class MapsController < AuthorizedController
  def index
    publications = []

    @skeleton_angles = Site.includes(
      graves: [:spines, :arrow]
    ).all.to_a.map do |site|
      spines = site.graves.joins(:tags).where(tags: {id: params[:tag_id]}).flat_map do |grave|
        grave.spines
      end

      angles = Stats.spine_angles(spines)

      {
        site: site,
        angles:,
        graves: spines.map(&:grave).uniq
      }
    end.filter do |grave_data|
      grave_data[:angles].values.sum > 0
    end

    @publications = @skeleton_angles.flat_map { _1[:graves] }.map(&:publication).uniq
  end
end
