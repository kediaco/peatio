class AddRemoteToMarket < ActiveRecord::Migration[5.2]
  def change
    add_column :markets, :remote, :boolean, after: :data_encrypted
  end
end
