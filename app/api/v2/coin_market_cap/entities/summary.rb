# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module CoinMarketCap
      module Entities
        class Summary < API::V2::Entities::Base
          expose(
            :trading_pairs,
            documentation: {
              type: String,
              desc: 'Identifier of a ticker with delimiter to separate base/quote, eg. BTC-USD (Price of BTC is quoted in USD).'
            }
          ) do |ticker|
            ticker.market.base_currency + "_" + ticker.market.quote_currency
          end

          expose(
            :LastPrice,
            documentation: {
              type: BigDecimal,
              desc: 'Last transacted price of base currency based on given quote currency.'
            }
          ) do |ticker|
            ticker[:last]
          end

          expose(
            :lowestAsk,
            documentation: {
              type: BigDecimal,
              desc: 'Lowest Ask price of base currency based on given quote currency.'
            }
          ) do |ticker|
            OrderAsk.get_depth(ticker[:market][:id]).first
          end

          expose(
            :highestBid,
            documentation: {
              type: BigDecimal,
              desc: 'Highest bid price of base currency based on given quote currency.'
            }
          ) do |ticker|
            OrderBid.get_depth(ticker[:market][:id]).first
          end

          expose(
            :baseVolume24h,
            documentation: {
              type: BigDecimal,
              desc: '24-hr volume of market pair denoted in BASE currency.'
            }
          ) do |ticker|
            ticker[:amount]
          end

          expose(
            :quoteVolume24h,
            documentation: {
              type: BigDecimal,
              desc: '24-hr volume of market pair denoted in QUOTE currency.'
            }
          ) do |ticker|
            ticker[:volume]
          end

          expose(
            :priceChangePercent24h,
            documentation: {
              type: BigDecimal,
              desc: '24-hr % price change of market pair.'
            }
          ) do |ticker|
            ticker[:open].zero? ? 0 : (ticker[:last] - ticker[:open]) / ticker[:open]
          end

          expose(
            :highestPrice24h,
            documentation: {
              type: BigDecimal,
              desc: 'Highest price of base currency based on given quote currency in the last 24-hrs.'
            }
          ) do |ticker|
            ticker[:high]
          end

          expose(
            :lowestPrice24h,
            documentation: {
              type: BigDecimal,
              desc: 'Lowest price of base currency based on given quote currency in the last 24-hrs.'
            }
          ) do |ticker|
            ticker[:low]
          end
        end
      end
    end
  end
end
