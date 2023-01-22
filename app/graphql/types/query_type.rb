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
      Bone.order(:name).all
    end

    field :periods, [PeriodType], null: false
    def periods
      Period.order(:name).all
    end

    field :cultures, [CultureType], null: false
    def cultures
      Culture.order(:name).all
    end

    field :mtHaplogroups, [MtHaplogroupType], null: false
    def mtHaplogroups
      MtHaplogroup.order(:name).all
    end

    field :yHaplogroups, [YHaplogroupType], null: false
    def yHaplogroups
      YHaplogroup.order(:name).all
    end

    field :graves, [Types::GraveType], null: false, description: 'Graves' do
      argument :offset, Int, required: true
      argument :limit, Int, required: true
      argument :name, String, required: false
    end
    def graves(offset:, limit:)
      Grave.order(:id).offset(offset).limit(limit)
    end

    field :grave, Types::GraveType, null: false do
      argument :id, Integer, required: true
    end
    def grave(id:)
      Grave.find(id)
    end

    field :graves_count, Int, null: false
    def graves_count
      Grave.count
    end

    field :publications, [Types::PublicationType], null: false
    def publications
      Publication.select(:id, :title, :author).order(:title).all
    end

    field :skeletons_count, Int, null: false
    def skeletons_count
      Skeleton.count
    end

    field :skeletons, [Types::SkeletonType], null: false, description: 'Graves' do
      argument :offset, Int, required: true
      argument :limit, Int, required: true
      argument :publication_id, ID, required: false
    end
    def skeletons(offset:, limit:, publication_id: nil)
      skeletons = Skeleton.order(:id).offset(offset).limit(limit)
      if publication_id.present?
        skeletons = skeletons.join(grave: { figure: { page: :publication } }).where(publication: { id: publication_id })
      end
      skeletons
    end

    field :skeleton, Types::SkeletonType, null: false, description: 'Graves' do
      argument :id, Integer, required: true
    end
    def skeleton(id:)
      Skeleton.find(id)
    end
  end
end
