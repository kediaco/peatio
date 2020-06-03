class AddStateToCurrencyModel < ActiveRecord::Migration[5.2]
  def change
    reversible do |direction|
      direction.up do
        add_column :currencies, :state, :string, after: :options
        Currency.find_each do |c|
          if c.visible && c.deposit_enabled && c.withdrawal_enabled
            c.update(state: :enabled)
          elsif !visible
            c.update(state: :disabled)
          end
        end
        remove_column :currencies, :visible
        remove_column :currencies, :deposit_enabled
        remove_column :currencies, :withdrawal_enabled
      end

      direction.down do
        add_column :currencies, :visible, :boolean, after: :options
        add_column :currencies, :deposit_enabled, :boolean, after: :visible
        add_column :currencies, :withdrawal_enabled, :boolean, after: :deposit_enabled
        Currency.find_each do |c|
          if c.state == 'enabled'
            c.update(visible: true)
          elsif c.state == 'disabled'
            c.update!(visible: false)
          end
        end
      end
    end
  end
end
