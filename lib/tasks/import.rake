namespace :import do
  task pdfs: :environment do
    Publication.transaction do
      Dir['pdfs/*.pdf'].each do |file|
        publication = Publication.create!(
          title: file,
          pdf: File.read(file)
        )

        AnalyzePublication.new.run(publication)
      rescue PDF::Reader::MalformedPDFError
        ap "faulty pdf: #{file}"
        publication.destroy
      end
    end
  end

  task sites: :environment do
    Site.transaction do
      # Site.delete_all

      # countries = CSV.read(Rails.root.join('assets', 'countries.csv').to_s, headers: true).map(&:to_h)

      table = CSV.parse(File.read('filtered.csv'), headers: true)

      # sites = table.map do |row|
      #   country_code = countries.filter { _1['name'] == row['Political Entity'] }.first&.[]('alpha-2')

      #   { name: row['Locality'],
      #     lat: row['Lat.'],
      #     lon: row['Long.'],
      #     country_code: country_code,
      #     locality: row['Locality']
      #   }
      # end.uniq { |r| r[:name] }

      # sites.each do |site|
      #   Site.create!(site)
      # end

      table.each do |row|
        dating = row['Full Date One of two formats. (Format 1) 95.4% CI calibrated radiocarbon age (Conventional Radiocarbon Age BP, Lab number) e.g. 2624-2350 calBCE (3990±40 BP, Ua-35016). (Format 2) Archaeological context range, e.g. 2500-1700 BCE']

        date = DatingParser.parse(dating)
        ap date
      end
    end
  end
end
