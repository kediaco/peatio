Sub funds through rails console for peatio 2.2.30
```ruby
member_uid = "U123456789"
currency_id = 'usd'
amount = 100
member = Member.find_by(uid: member_uid)

account = member.accounts.find_by(currency_id: currency_id)

ActiveRecord::Base.transaction do
    account.sub_funds(100)
    Operations::Liability.create(code: 201, currency_id: currency_id, member_id: member.id, debit: amount)
    Operations::Asset.create(code: 101, currency_id: currency_id, debit: amount)
end
```