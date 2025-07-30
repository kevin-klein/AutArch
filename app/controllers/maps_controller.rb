class MapsController < AuthorizedController
  def index
    @skeleton_angles = Site.includes(
      graves: [:spines, :arrow, :tags, :publication]
    ).all.to_a.map do |site|

      spines = site.graves.filter do |grave|
        grave.tags.any? { _1.id.to_s == params[:tag_id] }
      end.flat_map do |grave|
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

    @count = @skeleton_angles.map { _1[:angles].values.sum }.sum

    @site_ids = @skeleton_angles.flat_map { _1[:graves] }.map(&:site_id).uniq

    @publications = @skeleton_angles.flat_map { _1[:graves] }.map(&:publication).uniq
  end
end
