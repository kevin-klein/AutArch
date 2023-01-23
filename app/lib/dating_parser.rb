class DatingParser < Parslet::Parser

  def self.parse(s)
    parser = DatingParser.new

    parser.parse(s)
  rescue Parslet::ParseFailed => failure
    puts failure.parse_failure_cause.ascii_tree
    raise failure
  end
  root :date

  rule(:date) do
    c14_date.as(:c14) | context_date.as(:context)
  end

  rule(:lparen)     { str('(') >> space? }
  rule(:rparen)     { str(')') >> space? }
  rule(:comma)      { str(',') >> space? }
  rule(:space)      { match('\s').repeat(1) }
  rule(:space?)     { space.maybe }

  rule(:integer) { match('[0-9]').repeat(1) >> space? }

  rule :c14_date do
    space? >> date_range >> str('calBCE') >> space? >> c14_range_combine
  end

  rule :program_name do
    match('[a-zA-Z0-9\-\/\.]').repeat(1) >> space?
  end

  rule :date_range do
    integer.as(:from) >> space? >> str('-') >> integer.as(:to)
  end

  rule :bp_date do
    integer.as(:bp_number) >> str('±') >> space? >> integer.as(:uncertainty) >> space? >> str('BP').maybe
  end

  rule :c14_range do
    str('(') >> bp_date.as(:bp) >> space? >> (str(',') >> space? >> program_name.as(:software) >> space? >> (str(',') >> space? >> str('marine calibrated').as(:marine_calibrated)).maybe).maybe >> str(')')
  end

  rule :c14_range_combine do
    space? >> c14_range.maybe >> space? >> (str('[') >> (r_combine | union) >> str(']') >> space?).maybe
  end

  rule :union do
    str('union of two dates:') >> space? >> (c14_date >> str(';') >> space?).repeat(1) >> c14_date
  end

  rule :r_combine do
    str('R_combine') >> str(':') >> space? >> (c14_range >> str(';') >> space?).repeat(1) >> c14_range
  end

  rule :context_date do
    date_range >> space? >> str('BCE')
  end
end
