# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module CoinMarketCap
      class Summary < Grape::API
        desc 'Overview of market data for all tickers and all market pairs on the exchange.'
        get '/summary' do
          tikers = ::Market.ordered.inject({}) do |h, m|
            TickersService[m].ticker.merge(market: m)
          end
          present tickers, with: API::V2::CoinMarketCap::Entities::Summary
        end
      end
    end
  end
end
