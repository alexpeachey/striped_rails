class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.string :slug
      t.text :content
      t.integer :menu_order

      t.timestamps
    end
    add_index :pages, :slug, :unique => true
    add_index :pages, :menu_order
  end
end
