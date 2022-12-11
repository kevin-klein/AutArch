namespace :import do
  task sites: :environment do
    Site.delete_all

    table = CSV.parse(File.read("filtered.csv"), headers: true)

    sites = table.map do |row|
      { name: row['Locality'], lat: row['Lat.'], lon: row['Long.']}
    end.uniq { |r| r[:name] }

    Site.insert_all(sites)
  end
end
