class AddAdminNotesToAdmins < ActiveRecord::Migration[5.0]
  def change
    add_column :admins, :admin_notes, :text
  end
end
