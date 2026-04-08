class TextSummaryExtractor
  def extract_summaries(publication)
    graves = publication.figures.where(type: 'grave').where('probability > 0.6')

    identifiers = grave.map(&:identifier)

    # call python microservice
  end
end
