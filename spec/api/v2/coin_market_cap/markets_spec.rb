# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::CoinMarketCap::Markets, type: :request do

  describe 'GET /api/v2/coinmarketcap/orderbook/:market' do
    before do
      create_list(:order_bid, 5, :btcusd)
      create_list(:order_bid, 5, :btcusd, price: 2)
      create_list(:order_ask, 5, :btcusd)
      create_list(:order_ask, 5, :btcusd, price: 3)
    end

    let(:asks) { [["1.0", "5.0"], ["3.0", "5.0"]] }
    let(:bids) { [["2.0", "5.0"], ["1.0", "5.0"]] }

    let(:market) { :btcusd }

    context 'valid market param' do
      it 'sorts asks and bids from highest to lowest' do
        get "/api/v2/coinmarketcap/orderbook/BTC_USD"
        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result['asks']).to eq asks
        expect(result['bids']).to eq bids
      end
    end

    context 'invalid market param' do
      it 'validates market param' do
        api_get "/api/v2/coinmarketcap/orderbook/usdusd"
        expect(response).to have_http_status 422
        expect(response).to include_api_error('coinmarketcap.market.doesnt_exist')
      end
    end
  end

  describe 'GET /api/v2/coinmarketcap/trades/#{market}' do
    before { delete_measurments("trades") }
    let(:member) do
      create(:member, :level_3).tap do |m|
        m.get_account(:btc).update_attributes(balance: 12.13,   locked: 3.14)
        m.get_account(:usd).update_attributes(balance: 2014.47, locked: 0)
      end
    end

    let(:ask) do
      create(
        :order_ask,
        :btcusd,
        price: '12.32'.to_d,
        volume: '123.12345678',
        member: member
      )
    end

    let(:bid) do
      create(
        :order_bid,
        :btcusd,
        price: '12.32'.to_d,
        volume: '123.12345678',
        member: member
      )
    end
    let!(:ask_trade) { create(:trade, :btcusd, maker_order: ask, created_at: 2.days.ago) }
    let!(:bid_trade) { create(:trade, :btcusd, taker_order: bid, created_at: 1.day.ago) }


    after do
      delete_measurments('trades')
    end

    before do
      ask_trade.write_to_influx
      bid_trade.write_to_influx
    end

    let(:market) { :btcusd }

    it 'returns all recent trades' do
      get "/api/v2/coinmarketcap/trades/BTC_USD"

      expect(response).to be_successful
      expect(JSON.parse(response.body).size).to eq 2
    end


    it 'sorts trades in reverse creation order' do
      get "/api/v2/coinmarketcap/trades/BTC_USD"

      expect(response).to be_successful
      expect(JSON.parse(response.body).first['trade_id']).to eq bid_trade.id
    end

    it 'validates market param' do
      api_get "/api/v2/coinmarketcap/trades/BTC_TEST"
      expect(response).to have_http_status 422
      expect(response).to include_api_error('coinmarketcap.market.doesnt_exist')
    end
  end
end
