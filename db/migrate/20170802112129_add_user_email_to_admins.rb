class AddUserEmailToAdmins < ActiveRecord::Migration[5.0]
  def change
    add_column :admins, :user_email, :string
  end
end
