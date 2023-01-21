module Mutations
  class CreatePeriodMutation < BaseMutation
    argument :name, String

    field :period, Types::PeriodType

    def resolve(name:)
      period = Period.create!(name: name)
      {
        period: period
      }
    end
  end
end
