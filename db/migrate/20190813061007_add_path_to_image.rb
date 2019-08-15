class AddPathToImage < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :path, :string
  end
end
