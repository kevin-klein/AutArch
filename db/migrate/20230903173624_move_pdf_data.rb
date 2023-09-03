class MovePdfData < ActiveRecord::Migration[7.0]
  def change
    Publication.find_each do |publication|
      File.open("#{Rails.root.join('public/uploads/pdfs', publication.id.to_s).to_s}.pdf", "wb") do |file|
        file.write(publication.pdf)
      end
    end

    Image.find_each do |image|
      File.open("#{Rails.root.join('public/uploads/images', image.id.to_s).to_s}.jpg", "wb") do |file|
        file.write(image.data)
      end
    end

    remove_column :images, :data
    remove_column :publications, :pdf
  end
end
