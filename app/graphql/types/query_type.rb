module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :sites, [LocationType], null: false do
      argument :search, String, required: false
    end
    def sites(search: nil)
      if search.present?
        Site.where('name ilike ?', "%#{search}%")
      else
        Site.all
      end
    end

    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World!"
    end

    field :bones, [BoneType], null: false
    def bones
      Bone.all
    end

    field :periods, [PeriodType], null: false
    def periods
      Period.all
    end

    field :graves, [Types::GraveType], null: false, description: 'Graves' do
      argument :offset, Int, required: true
      argument :limit, Int, required: true
      argument :name, String, required: false
    end
    def graves(offset:, limit:)
      Grave.offset(offset).limit(limit)
    end

    field :skeletons, [Types::SkeletonType], null: false, description: 'Graves' do
      argument :offset, Int, required: true
      argument :limit, Int, required: true
      argument :name, String, required: false
    end
    def skeletons(offset:, limit:)
      Skeleton.offset(offset).limit(limit)
    end

    field :skeleton, Types::SkeletonType, null: false, description: 'Graves' do
      argument :id, Integer, required: true
    end
    def skeleton(id:)
      Skeleton.find(id)
    end
  end
end
