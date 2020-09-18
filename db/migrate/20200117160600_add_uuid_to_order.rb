class AddUUIDToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :uuid, :binary, limit: 16, after: :id, null: false
    execute('UPDATE orders SET uuid = (UNHEX(REPLACE(UUID(), "-",""))) WHERE LENGTH(uuid) = 0')
    add_index :orders, :uuid, unique: true
    add_column :orders, :remote_id, :string, after: :uuid
  end
end
