class CreateAdmins < ActiveRecord::Migration[5.0]
  def change
    create_table :admins do |t|
      t.string :title
      t.text :searchblocks
      t.string :creators
      t.text :notes
      t.string :keywords
      t.integer :sid
      t.date :creationdate

      t.timestamps
    end
    add_index :admins, :sid, unique: true
  end
end
