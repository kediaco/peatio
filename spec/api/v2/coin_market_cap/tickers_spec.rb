# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::CoinMarketCap::Tickers, type: :request do
  describe 'GET /api/v2/coinmarketcap/ticker' do
    after { delete_measurments("trades") }
    before do
      create_list(:order_bid, 5, :btcusd)
      create_list(:order_ask, 5, :btcusd)
    end

    context 'no trades executed yet' do
      let(:expected_ticker) do
        {
          'last_price' => '0.0',
          'quote_volume' => '0.0', 'base_volume' => '0.0',
          'isFrozen' => 0 }
      end

      it 'returns ticker of all markets' do
        get '/api/v2/coinmarketcap/ticker'
        expect(response).to be_successful

        expect(JSON.parse(response.body)['BTC_USD']).to include(expected_ticker)
      end
    end

    context 'single trade was executed' do
      let!(:trade) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d)}

      let(:expected_ticker) do
        { 'last_price' => '5.0', 'quote_volume' => '5.5',
          'base_volume' => '1.1', 'isFrozen' => 0
           }
      end

      let(:expected_frozen_ticker) do
        { 'last_price' => '5.0', 'quote_volume' => '5.5',
          'base_volume' => '1.1', 'isFrozen' => 1
           }
      end

      before do
        trade.write_to_influx
      end

      it 'returns market tickers' do
        get '/api/v2/coinmarketcap/ticker'
        expect(response).to be_successful
        expect(JSON.parse(response.body)['BTC_USD']).to include(expected_ticker)
      end

      it 'returns market ticked with frozen market' do
        Market.find('btcusd').update(state: 'disabled')
        get '/api/v2/coinmarketcap/ticker'
        expect(response).to be_successful
        expect(JSON.parse(response.body)['BTC_USD']).to include(expected_frozen_ticker)
      end
    end

    context 'multiple trades were executed' do
      let!(:trade1) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d)}
      let!(:trade2) { create(:trade, :btcusd, price: '6.0'.to_d, amount: '0.9'.to_d, total: '5.4'.to_d)}

      let(:expected_ticker) do
        { 'last_price' => '6.0',
          'quote_volume' => '10.9', 'base_volume' => '2.0',
          'isFrozen' => 0 }
      end
      before do
        trade1.write_to_influx
        trade2.write_to_influx
      end

      it 'returns market tickers' do
        get '/api/v2/coinmarketcap/ticker'
        expect(response).to be_successful
        expect(JSON.parse(response.body)['BTC_USD']).to include(expected_ticker)
      end
    end
  end
end
