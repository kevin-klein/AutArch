class MovePdfData < ActiveRecord::Migration[7.0]
  def change
    Publication.find_each do |publication|
      File.binwrite("#{Rails.root.join("public/uploads/pdfs", publication.id.to_s)}.pdf", publication.pdf)
    end

    Image.find_each do |image|
      File.binwrite("#{Rails.root.join("public/uploads/images", image.id.to_s)}.jpg", image.data)
    end

    remove_column :images, :data
    remove_column :publications, :pdf
  end
end
