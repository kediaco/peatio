# frozen_string_literal: true

module API
  module V2
    module CoinMarketCap
      class Mount < Grape::API
        PREFIX = '/coinmarketcap'

        before { set_ets_context! }

        helpers CoinMarketCap::Helpers

        mount CoinMarketCap::Assets
        mount CoinMarketCap::Tickers
        mount CoinMarketCap::Markets
      end
    end
  end
end
