class AddAlsoToAdmins < ActiveRecord::Migration[5.0]
  def change
    add_column :admins, :also, :string
  end
end
