class ChangeImagesToFolderStructure < ActiveRecord::Migration[7.0]
  def up
    Image.find_each do |image|
      data = image.data
      File.binwrite(image.file_path, data)
    rescue ActiveStorage::FileNotFoundError
      # image.destroy!
    end
  end

  def down
    remove_column :images, :path
  end
end
