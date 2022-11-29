COUNTRIES = "Albania
Austria
Bulgaria
Channel Islands
Croatia
Czech Repulic
Denmark
Estonia
France
Germany
Greece
Hungary
Italy
Kazakhstan
Latvia
Lithuania
Moldova
Montenegro
Netherlands
North Macedonia
Poland
Portugal
Russia
Serbia
Slovakia
Slovenia
Spain
Sweden
Switzerland
Ukraine
United
Kingdom".split("\n")

CSV.open('filtered.csv', 'w') do |filtered|
  filtered << CSV.read('v54.1_HO_public.csv', col_sep: "\t", quote_char: nil, headers: true).headers
  CSV.foreach('v54.1_HO_public.csv', col_sep: "\t", quote_char: nil, headers: true) do |row|
    age = row['Date mean in BP in years before 1950 CE [OxCal mu for a direct radiocarbon date, and average of range for a contextual date]'].to_i
    if age < 3500 && age > 1800 && COUNTRIES.include?(row['Political Entity']) && row['Lat.'] != '..' && row['Long.'] != '..'
      filtered << row
    end
  end
end
