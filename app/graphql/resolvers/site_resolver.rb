module Resolvers
  class SiteResolver < BaseResolver
    type Types::SiteType, null: false
    argument :id, ID

    def resolve(id:)
      ::Site.find(id)
    end
  end
end
