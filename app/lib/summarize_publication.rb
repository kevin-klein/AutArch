class SummarizePublication
  def run(publication)
    texts = publication.pages.map { _1.page_texts.map(&:text).join(" ") }.join(" ")

    summaries = texts
    while summaries.split(".").length > 6
      ap summaries.length
      summaries = split_text_into_sentences(summaries)
      summaries = summaries.map do |text|
        result = query("summarize:#{text}")
        result = "#{result}." if result.last != "."
        result
      end.join(" ")
    end

    publication.summary = summaries
    publication.save!
  end

  def query(text)
    response = HTTP.post("#{ENV["ML_SERVICE_URL"]}/summary", form: {
      text: text
    })

    response.parse["summary"]
  end

  private

  def split_text_into_sentences(text, max_chars = 2048)
    sentences = text.split(".").map { |s| s.strip }.reject(&:empty?)

    sentences.each_with_object([]) do |sentence, result|
      sentence_with_dot = sentence + "."

      if result.empty?
        result << sentence_with_dot
      else
        last_sentence = result.last
        current_word_count = last_sentence.size + sentence_with_dot.size

        if current_word_count <= max_chars
          result[-1] = last_sentence + " " + sentence_with_dot
        else
          result << sentence_with_dot
        end
      end
    end
  end
end
