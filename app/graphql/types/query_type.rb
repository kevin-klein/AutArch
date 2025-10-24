module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :site, resolver: Resolvers::SiteResolver
    field :publication, resolver: Resolvers::PublicationResolver
  end
end
