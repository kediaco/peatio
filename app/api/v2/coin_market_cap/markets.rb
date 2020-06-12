# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module CoinMarketCap
      class Markets < Grape::API
        desc 'Get depth or specified market. Both asks and bids are sorted from highest price to lowest.'
        params do
          requires :market_pair,
                   type: String,
                   values: { value: -> { ::Market.active.map { |m| m.base_unit.upcase + "_" + m.quote_unit.upcase } },
                             message: 'coinmarketcap.market.doesnt_exist' },
                   desc: -> { V2::Entities::Market.documentation[:id] }
          optional :depth,
                   type: { value: Integer, message: 'coinmarketcap.market_depth.non_integer_depth' },
                   values: { value: 1..1000, message: 'coinmarketcap.market_depth.invalid_depth' },
                   default: 300,
                   desc: 'Limit the number of returned price levels. Default to 300.'
        end
        get "/orderbook/:market_pair" do
          market_name = params[:market_pair].split('_').map(&:downcase).join
          asks = OrderAsk.get_depth(market_name)[0, params[:depth]]
          bids = OrderBid.get_depth(market_name)[0, params[:depth]]
          { timestamp: Time.now.to_i, asks: asks, bids: bids }
        end

        desc 'Get recent trades on market, each trade is included only once. Trades are sorted in reverse creation order.',
        is_array: true
        params do
          requires :market_pair,
                  type: String,
                  values: { value: -> { ::Market.active.map { |m| m.base_unit.upcase + "_" + m.quote_unit.upcase } },
                            message: 'coinmarketcap.market.doesnt_exist' },
                  desc: -> { V2::Entities::Market.documentation[:id] }
        end
        get "/trades/:market_pair" do
          market_name = params[:market_pair].split('_').map(&:downcase).join
          present Trade.public_from_influx(market_name), with: API::V2::CoinMarketCap::Entities::PublicTrade
        end
      end
    end
  end
end
