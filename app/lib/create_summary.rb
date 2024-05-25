class CreateSummary
  # from: http://www.wordcount.org/dbquery.php?toFind=#{i}&method=SEARCH_BY_INDEX
  COMMON_TERMS = %w[of and to a in that it is was i
    for on you he be with as by at have are
    this not but had his they from she which or
    we an there her were one do been all their
    has would will what if can when so no said
    who more about up them some could him into its
    then two out time like only my did other me
    your now over just may these new also people any
    know very see first well after should than where].freeze

  def run(publication)
    frequencies = {}
    publication.pages.find_each do |page|
      text = page.page_texts.map(&:text).join(" ")
      frequencies = frequency(text, frequencies)
    end

    frequencies = merge_items_by_distance(frequencies)
    frequencies
      .map { |term, count| [term, count] }
      .sort_by { |_term, count| count }
      .last(15)
  end

  def frequency(text, frequencies)
    text = text.gsub(/[^0-9a-z ]/i, "")
    text = text
      .split

    text
      .filter! do
        _1.length > 4 && COMMON_TERMS.exclude?(_1)
      end

    text.tally(frequencies)
  end

  def merge_items_by_distance(frequencies)
    frequencies.each do |item, count|
      matcher = Amatch::DamerauLevenshtein.new(item)
      same = find_same_frequency(frequencies, matcher)
      if same.present? && same[0] != item
        frequencies[same[0]] += count
        true
      else
        false
      end
    end
  end

  def find_same_frequency(frequencies, matcher)
    frequencies
      .to_a
      .select { |key, _val| matcher.similar(key) > 0.8 }
      .first
  end
end
