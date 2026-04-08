FactoryBot.define do
  factory :publication do
    title { SecureRandom.hex(12) }
    author { SecureRandom.hex(12) }
    year { '2023' }
    public { false }

    factory :publication_with_pages do
      transient { pages_count { 3 } }

      after(:create) do |publication, evaluator|
        create_list(:page, evaluator.pages_count, publication: publication)
        # Attach a mock PDF file
        file = Rails.root.join('spec', 'fixtures', 'files', 'test.pdf')
        if File.exist?(file)
          publication.pdf.attach(
            io: File.open(file),
            filename: 'test.pdf',
            content_type: 'application/pdf'
          )
        end
      end
    end
  end
end
