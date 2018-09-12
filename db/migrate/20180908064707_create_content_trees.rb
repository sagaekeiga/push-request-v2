class CreateContentTrees < ActiveRecord::Migration[5.1]
  def change
    create_table :content_trees do |t|
      t.belongs_to :parent, index: true
      t.belongs_to :child, index: true
      t.timestamps
    end
  end
end
