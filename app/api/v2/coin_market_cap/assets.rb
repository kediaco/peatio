# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module CoinMarketCap
      class Assets < Grape::API
        desc 'Get list of assets.'
        get '/assets' do
          Currency.visible.ordered.inject({}) do |h, c|
            currency_name = c.id.upcase
            h[currency_name] = format_currency(c)
            h
          end
        end
      end
    end
  end
end
