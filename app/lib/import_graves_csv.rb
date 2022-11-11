class ImportGravesCsv

  def import
    publications = {}

    CSV.foreach(Rails.root.join('graves.csv'), headers: true) do |row|
      name = row['file'].split('-')[...-1].join('-')

      publication = publications[name]
      if publication.nil?
        publication = Publication.create!(name: name)
        publications[name] = publication
      end

      x1 = row['x1']
      x2 = row['x2']
      y1 = row['y1']
      y2 = row['y2']

      name = row['class']

      publication.figures.create!({ x1:, y1:, x2:, y2:, name: })
    end
  end

end
