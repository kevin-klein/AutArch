class ImportGravesCsv

  def import
    publications = {}

    Publication.transaction do
      CSV.foreach(Rails.root.join('graves.csv'), headers: true) do |row|
        name = row['file'].split('-')[...-1].join('-')

        page = row['file'].split('-')[-1].gsub('.jpg', '').to_i

        publication = publications[name]
        if publication.nil?
          publication = Publication.create!(title: name)
          publications[name] = publication
        end

        page = publication.pages.find_or_initialize_by(number: page)

        image_data = File.read(Rails.root.join('pdfs', 'page_images', row['file']))

        x1 = row['x1']
        x2 = row['x2']
        y1 = row['y1']
        y2 = row['y2']

        type_name = row['class']

        page.image = Image.create!(data: image_data)
        page.save!
        page.figures.create!({ x1:, y1:, x2:, y2:, type_name:, tags: [] })
      end
    end
  end
end
