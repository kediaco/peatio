# frozen_string_literal: true

describe API::V2::Admin::Accounting, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:member) { create(:member) }

  describe 'GET /api/v2/admin/balance_sheet' do
    it 'get default balance_sheet' do
      api_get '/api/v2/admin/balance_sheet', token: token

      expect(response).to be_successful
      expect(response_body.key?('assets')).to be_truthy
      expect(response_body.key?('liabilities')).to be_truthy
      expect(response_body.key?('balance')).to be_truthy
    end

    it 'returns balance_sheet sheet after deposits' do
      d_usd = create(:deposit_usd, member: member, fee: 1, amount: 10)
      d_usd.accept!
      d_btc = create(:deposit_btc, member: member, amount: 10)
      d_btc.accept!

      api_get '/api/v2/admin/balance_sheet', token: token

      expect(response).to be_successful
      expect(response_body['assets']['usd']).to eq((d_usd.amount + d_usd.fee).to_s)
      expect(response_body['liabilities']['usd']).to eq(d_usd.amount.to_s)
      expect(response_body['assets']['btc']).to eq(d_btc.amount.to_s)
      expect(response_body['liabilities']['btc']).to eq(d_btc.amount.to_s)
      expect(response_body['balance']['usd']).to eq(d_usd.fee.to_s)
    end
  end
end
