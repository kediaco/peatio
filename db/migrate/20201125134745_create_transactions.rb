class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.string :currency_id
      t.string :reference_type
      t.integer :reference_id
      t.string :hash
      t.string :from_address
      t.string :to_address
      t.decimal :amount
      t.integer :txout
      t.string :status
      t.json :options
      t.timestamps
    end
    add_index :transactions, %i[currency_id]
  end
end
