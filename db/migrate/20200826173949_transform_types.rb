class TransformTypes < ActiveRecord::Migration[5.2]
  Z_TYPE = { swift: 0, card: 1, sepa: 2 , crypto: 3 }.freeze
  def change
    Deposit.find_each do |d|
      type = Z_TYPE.key(d.z_type)
      d.update(transfer_type: type)
    end

    Withdraw.find_each do |w|
      type = Z_TYPE.key(w.z_type)
      w.update(transfer_type: type)
    end

    remove_column :deposits, :z_type if column_exists?(:deposits, :z_type)
    remove_column :withdraws, :z_type if column_exists?(:withdraws, :z_type)
  end
end
