class ExportPublication
  include FiguresHelper

  def export(publication)
    graves = publication.graves

    create_graves_csv(graves)
    create_outlines_csv(graves)
    create_stacked_outlines_svg(graves)

    File.unlink("export.zip") if File.exist?("export.zip")
    files = []

    Zip::File.open("export.zip", create: true) do |zip|
      zip.add("graves.csv", "graves.csv")
      zip.add("grave outlines.csv", "grave_outlines.csv")
      zip.add("stacked outlines.svg", "stacked outlines.svg")

      zip.mkdir("outlines")
      graves.each do |grave|
        file = create_outlines_svg(grave)
        zip.add("outlines/#{grave.identifier}.svg", file)
        files << file
      end
    end

    files.each { File.unlink(_1) }
    File.unlink("graves.csv")
    File.unlink("grave_outlines.csv")
    File.unlink("stacked outlines.svg")
  end

  def create_outlines_csv(graves)
    CSV.open("grave_outlines.csv", "wb") do |csv|
      graves.each do |grave|
        csv << if grave.manual_bounding_box
          [grave.identifier, grave.manual_contour].flatten
        else
          [grave.identifier, grave.contour].flatten
        end
      end
    end
  end

  def create_outlines_svg(grave)
    data = ApplicationController.render(GraveOutlinesComponent.new(
      color: [0, 0, 0],
      subtitle: "#{grave.publication.title} #{grave.publication.author} #{grave.publication.year}",
      title: grave.identifier,
      graves: [grave],
      compact: true
    ), layout: false)

    file_name = "#{grave.id}.svg"
    File.write(file_name, data)
    file_name
  end

  def create_stacked_outlines_svg(graves)
    data = ApplicationController.render(GraveOutlinesComponent.new(
      color: [0, 0, 0],
      subtitle: nil,
      title: nil,
      graves: graves,
      compact: true
    ), layout: false)

    file_name = "stacked outlines.svg"
    File.write(file_name, data)
    file_name
  end

  def create_graves_csv(graves)
    headers = ["Identifier", "Site-ID", "Tags", "Width", "Length", "Skeletal Orientation", "Bounding Box Orientation"]

    CSV.open("graves.csv", "wb", headers: headers, write_headers: true) do |csv|
      graves.each do |grave|
        orientation = if grave.arrow.present?
          ((grave.angle.abs.round + grave.arrow.angle) % 180).round
        else
          ''
        end

        csv << {
          "Identifier" => grave.identifier,
          "Site-ID" => grave.site&.id,
          "Tags" => grave.tags.map(&:name).join(", "),
          "Width" => number_with_unit(grave.width_with_unit),
          "Length" => number_with_unit(grave.height_with_unit),
          "Skeletal Orientation" => Stats.all_spine_angles(grave.spines).join(", "),
          "Bounding Box Orientation" => orientation
        }
      end
    end
  end
end
