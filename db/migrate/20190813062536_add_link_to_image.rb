class AddLinkToImage < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :link, :string
  end
end
