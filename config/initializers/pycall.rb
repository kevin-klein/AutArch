module PyCall
  module_function

  def enum(generator)
    Enumerator.new do |enum|
      begin
        loop do
          enum << PyCall.builtins.next(generator)
        end
      rescue PyError => err
        raise err unless err.type.to_s.match?("StopIteration")
      end
    end
  end
end
