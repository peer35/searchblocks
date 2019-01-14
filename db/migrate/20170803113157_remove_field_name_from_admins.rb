class RemoveFieldNameFromAdmins < ActiveRecord::Migration[5.0]
  def change
    remove_column :admins, :sid, :integer
  end
end
