class Transaction < ApplicationRecord
end

# == Schema Information
# Schema version: 20201125134745
#
# Table name: transactions
#
#  id             :bigint           not null, primary key
#  currency_id    :string(255)
#  reference_type :string(255)
#  reference_id   :integer
#  hash           :string(255)
#  from_address   :string(255)
#  to_address     :string(255)
#  amount         :decimal(10, )
#  txout          :integer
#  status         :string(255)
#  options        :json
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_transactions_on_currency_id  (currency_id)
#
