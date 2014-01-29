##
# Removes obsolete tables and columns that, for whatever reason, were not deleted before.
class RemoveObsoleteTablesAndColumns < ActiveRecord::Migration
  def up
    drop_table :principal_roles if ActiveRecord::Base.connection.table_exists? 'principal_roles'

    remove_column :repositories, :checkout_settings
    remove_column :roles, :type
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't recover the deleted tables and columns."
  end
end
