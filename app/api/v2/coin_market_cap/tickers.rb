# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module CoinMarketCap
      class Tickers < Grape::API
        desc 'Get 24-hour pricing and volume summary for each market pair'
        get '/ticker' do
          ::Market.ordered.inject({}) do |h, m|
            market_name = m.base_currency.upcase + "_" + m.quote_currency.upcase
            h[market_name] = format_ticker(TickersService[m].ticker, m)
            h
          end
        end
      end
    end
  end
end
