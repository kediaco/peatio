# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module CoinMarketCap
      module Entities
        class PublicTrade < API::V2::Entities::Base
          expose(
            :trade_id,
            documentation: {
              type: String,
              desc: 'A unique ID associated with the trade for the currency pair transaction.'
            }
          ) do |trade|
            trade[:id]
          end

          expose(
            :price,
            documentation: {
              type: BigDecimal,
              desc: 'Transaction price in base pair volume.'
            }
          )

          expose(
            :base_volume,
            documentation: {
              type: BigDecimal,
              desc: 'Transaction amount in base pair volume.'
            }
          ) do |trade|
            trade[:amount]
          end

          expose(
            :quote_volume,
            documentation: {
              type: BigDecimal,
              desc: 'Transaction amount in quote pair volume.'
            }
          ) do |trade|
            trade[:total]
          end

          expose(
            :type,
            documentation: {
              type: String,
              desc: 'Trade taker order type (sell or buy).'
            }
          ) do |trade|
            trade[:taker_type]
          end

          expose(
            :timestamp,
            documentation: {
              type: Integer,
              desc: 'Unix timestamp in milliseconds for when the transaction occurred.'
            }
          ) do |trade|
            trade[:created_at].to_i
          end
        end
      end
    end
  end
end
