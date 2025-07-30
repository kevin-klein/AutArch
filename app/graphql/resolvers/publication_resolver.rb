module Resolvers
  class PublicationResolver < BaseResolver
    type Types::PublicationType, null: false
    argument :id, ID

    def resolve(id:)
      ::Publication.find(id)
    end
  end
end
