class CreateWidgets < ActiveRecord::Migration[5.1]
  def change
    create_table :widgets do |t|
      t.string :name
      t.integer :price
      t.string :tags, array: true
      t.hstore :metadata

      t.timestamps
    end
  end
end
