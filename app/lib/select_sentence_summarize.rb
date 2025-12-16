class SelectSentenceSummarize
  STOP_WORDS = %w[
    the a an and or but in on at to for of with by as is was were be been
    have has had do does did will would could should may might must
  ].freeze

  def initialize(text)
    @text = text.to_s.strip
    @stemmer = Mittens::Stemmer.new
    @tagger = EngTagger.new
  end

  def summarize_with_nlp(sentence_count = 3)
    return "" if @text.empty?

    sentences = preprocess_sentences(@text)
    return sentences.first(sentence_count).join(" ").strip + "." if sentences.size <= sentence_count

    global_freq = build_word_frequency(@text)      # {stem => freq}
    sentence_scores = score_sentences(sentences, global_freq)

    select_top_sentences(sentences, sentence_scores, sentence_count).join(" ").strip + "."
  end

  private

  # --- Preprocessing ---

  def preprocess_sentences(text)
    sentences = split_sentences(text)
    remove_invalid_sentences(sentences)
  end

  def split_sentences(text)
    text.split(/(?<=[.!?])\s+/).map(&:strip).reject(&:empty?)
  end

  def remove_invalid_sentences(sentences)
    sentences.reject { |s| s.count("\n") > 3 || !contains_verb?(s) }
  end

  def contains_verb?(sentence)
    tagged = @tagger.add_tags(sentence)
    verbs = safe_hash(@tagger.get_verbs(tagged))
    !verbs.empty?
  end

  # --- Tokenization & Frequency building (preserve tagger counts) ---

  # Build a normalized (stemmed, downcased) frequency hash for the whole text
  def build_word_frequency(text)
    tagged = @tagger.add_tags(text)
    nouns = safe_hash(@tagger.get_nouns(tagged))
    adjectives = safe_hash(@tagger.get_adjectives(tagged))
    verbs = safe_hash(@tagger.get_verbs(tagged))

    merge_and_normalize_counts(nouns, adjectives, verbs)
  end

  # Merge multiple {word => count} hashes and normalize keys (downcase + stem).
  # Also removes stop words after downcasing (before stemming) for safety.
  def merge_and_normalize_counts(*pos_hashes)
    merged = Hash.new(0)

    pos_hashes.each do |h|
      h.each do |word, cnt|
        next if word.nil? || word.strip.empty?
        lc = word.to_s.downcase
        next if STOP_WORDS.include?(lc)
        stem = @stemmer.stem(lc)
        merged[stem] += cnt.to_i
      end
    end

    merged
  end

  # Convert tagger output (which may be nil) to a hash safely
  def safe_hash(value)
    case value
    when Hash then value
    when NilClass then {}
    else
      # Some versions may return arrays; attempt to coerce
      if value.respond_to?(:to_h)
        value.to_h
      else
        {}
      end
    end
  end

  # --- Scoring ---

  # For each sentence, use the tagger's counts for that sentence (preserved),
  # normalize them (stem/lowercase), then compute:
  # freq_score = sum_over_terms( sentence_term_count * global_freq[term] )
  def score_sentences(sentences, global_freq)
    sentences.to_h do |sentence|
      tagged = @tagger.add_tags(sentence)
      nouns = safe_hash(@tagger.get_nouns(tagged))
      adjectives = safe_hash(@tagger.get_adjectives(tagged))
      verbs = safe_hash(@tagger.get_verbs(tagged))

      sentence_term_counts = merge_and_normalize_counts(nouns, adjectives, verbs) # {stem => count_in_sentence}
      freq_score = sentence_term_counts.sum { |stem, cnt| cnt * (global_freq[stem] || 0) }

      proper_bonus = count_proper_nouns(sentence) * 0.5
      length_factor = length_penalty(sentence_term_counts.values.sum)

      [sentence, (freq_score + proper_bonus) * length_factor]
    end
  end

  def count_proper_nouns(sentence)
    sentence.scan(/\b[A-Z][a-z]+\b/).size
  end

  def length_penalty(word_count)
    case word_count
    when 0..4 then 0.2
    when 41..Float::INFINITY then 0.4
    else 1.0
    end
  end

  # --- Selection ---

  def select_top_sentences(sentences, scores, count)
    top = scores.sort_by { |_s, score| -score }.first([count, sentences.length].min).map(&:first)
    # preserve original order
    sentences.select { |s| top.include?(s) }.first(count)
  end
end
