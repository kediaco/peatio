# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::CoinMarketCap::Assets, type: :request do
  describe 'GET /api/v2/coinmarketcap/assets' do

    let!(:currency) {
      {"id"=>"usd", "name"=>"US Dollar", "can_withdraw"=>true, "can_deposit"=>true, "min_withdraw"=>"0.0"}
    }

    it 'lists visible currencies' do
      get '/api/v2/coinmarketcap/assets'
      expect(response).to be_successful

      result = JSON.parse(response.body)

      expect(result.size).to eq Currency.visible.size
      expect(result["USD"]).to eq currency
    end
  end
end
