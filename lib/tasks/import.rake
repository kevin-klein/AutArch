namespace :import do
  task sites: :environment do
    Site.transaction do
      Site.delete_all

      countries = CSV.read(Rails.root.join('assets', 'countries.csv').to_s, headers: true).map(&:to_h)

      table = CSV.parse(File.read("filtered.csv"), headers: true)

      sites = table.map do |row|
        country_code = countries.filter { _1['name'] == row['Political Entity'] }.first&.[]('alpha-2')

        { name: row['Locality'],
          lat: row['Lat.'],
          lon: row['Long.'],
          country_code: country_code,
          locality: row['Locality']
        }
      end.uniq { |r| r[:name] }

      sites.each do |site|
        Site.create!(site)
      end
    end
  end
end
