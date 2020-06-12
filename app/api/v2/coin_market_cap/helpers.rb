# frozen_string_literal: true

module API
  module V2
    module CoinMarketCap
      module Helpers
        def format_ticker(ticker, market)
          {
            last_price: ticker[:last],
            base_volume: ticker[:amount],
            quote_volume: ticker[:volume],
            isFrozen: market.state.enabled? ? 0 : 1
          }
        end

        def format_currency(currency)
          {
            id: currency.id,
            name: currency.name,
            can_withdraw: currency.withdrawal_enabled,
            can_deposit: currency.deposit_enabled,
            min_withdraw: currency.min_withdraw_amount
          }
        end
      end
    end
  end
end
