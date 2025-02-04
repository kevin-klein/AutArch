class ArtefactsHeatmap
  def run(publication)
    graves = []
    artefacts = []

    publication.figures.where(type: "Spine").each do |spine|
      grave = spine.grave

      grave_outside = grave.rotate_bounding_box(-spine.angle)
      grave_contour = MinOpenCV.boundingRect(
        grave
        .rotate_contour(-spine.angle)
        .map do |point|
          [point.first + grave_outside.first.first, point.second + grave_outside.first.second]
        end
      )

      result_grave_contour = grave.size_ignoring_contour(angle: -spine.angle)
      graves << result_grave_contour

      artefacts << grave.artefacts
        .map { _1.rotate_bounding_box(-spine.angle) }
        .map { [(_1.first.first + _1.second.first) / 2, (_1.first.second + _1.second.second) / 2] } # convert to center
        .map { [_1.first - grave_contour[:x], _1.second - grave_contour[:y]] } # relative to the grave bounding box
        .map { [_1.first.to_f / grave_contour[:width], _1.second.to_f / grave_contour[:height]] } # relative percentage of grave
    end

    {graves:, artefacts: artefacts.flatten(1)}
  end
end
