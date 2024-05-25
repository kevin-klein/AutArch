class DatingParser < Parslet::Parser
  def fallback_parse(text) # rubocop:disable Metrics/MethodLength
    if s.include?("calBCE")
      bps = s.scan(%r{([0-9]+)±([0-9]+)BP[;|,]?([a-zA-Z0-9\-/. ;]*)})
      {
        c14: {
          notes: text,
          c14_details: {
            combine: bps.map do |bp_number, uncertainty, labcode|
              {
                bp_number: bp_number,
                uncertainty: uncertainty,
                labcode: labcode
              }
            end
          }
        }
      }
    else
      match_data = text.match(/([0-9]+)-([0-9]+)/)
      {
        context: {
          from: match_data[1],
          to: match_data[2]
        }
      }
    end
  end

  def self.parse(text)
    parser = DatingParser.new
    text = text.delete(" ")
    parser.parse(text)
  rescue Parslet::ParseFailed => e
    Rails.logger.debug e.parse_failure_cause.ascii_tree
    # raise failure
    Rails.logger.debug parser.fallback_parse(s)
  end
  root :date

  rule(:date) do
    c14_date.as(:c14) | context_date.as(:context)
  end

  rule(:lparen) { str("(") }
  rule(:rparen) { str(")") }
  rule(:comma) { str(",") }

  rule(:integer) { match("[0-9]").repeat(1) }

  rule :c14_date do
    date_range >> str("calBCE") >> c14_range_combine.as(:c14_details)
  end

  rule :labcode do
    match('[a-zA-Z0-9\-\/\. \;]').repeat(1).as(:labcode) >>
      (str(",") >>
        (str("marinecalibrated").as(:marine_calibrated) | match('[a-zA-Z0-9\-]').repeat(1).as(:note))).repeat >>
      mp.maybe
  end

  rule :mp do
    str("(Mp)")
  end

  rule :date_range do
    integer.as(:from) >> str("-") >> integer.as(:to)
  end

  rule :bp_date do
    integer.as(:bp_number) >> str("±") >> integer.as(:uncertainty) >> str("BP").maybe
  end

  rule :c14_range do
    str("(") >> bp_date >> (str(",") >> labcode).maybe >> str(")")
  end

  rule :c14_range_combine do
    c14_range.maybe >> (str("[") >> (r_combine.as(:combine) | union.as(:combine)) >> str("]")).maybe
  end

  rule :union do
    str("unionoftwodates:") >> (c14_date >> (str(";") | str(","))).repeat(1) >> c14_date
  end

  rule :r_combine do
    str("R_combine") >> str(":") >> (c14_range >> (str(";") | str(","))).repeat(1) >> c14_range
  end

  rule :context_date do
    date_range >> str("BCE")
  end
end
