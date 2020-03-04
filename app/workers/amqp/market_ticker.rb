# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module AMQP
    class MarketTicker < Base

      FRESH_TRADES = 80

      def initialize
        @tickers = Hash.new { |hash, market_id| initialize_market_data(Market.find(market_id)) }
        @trades  = Hash.new { |hash, market_id| initialize_market_data(Market.find(market_id)) }
        # NOTE: Update ticker only for enabled markets.

        Market.enabled.each(&method(:initialize_market_data))
      end

      def process(payload, _metadata, _delivery_info)
        payload.symbolize_keys!
        update_ticker payload
        update_latest_trades payload
      end

      def update_ticker(trade)
        ticker        = @tickers[trade[:market_id]]
        ticker[:low]  = get_market_low trade[:market_id], trade
        ticker[:high] = get_market_high trade[:market_id], trade
        ticker[:open] = get_market_open trade[:market_id], trade
        ticker[:last] = trade[:price].to_d
        Rails.logger.info { "Update ticker for market: #{trade[:market_id]}, ticker: #{ticker.inspect}" }
        Rails.cache.write "peatio:#{trade[:market_id]}:ticker", ticker
      end

      def update_latest_trades(trade)
        trades = @trades[trade[:market_id]]
        trades.unshift(trade)
        trades.pop if trades.size > FRESH_TRADES

        Rails.cache.write "peatio:#{trade[:market_id]}:trades", trades
      end

      def initialize_market_data(market)
        trades = Trade.public_from_influx(market.id, FRESH_TRADES)

        @trades[market.id] = trades
        Rails.cache.write "peatio:#{market.id}:trades", @trades[market.id]

        ticker_init = Trade.market_ticker_from_influx(market.id)

        if ticker_init.present?
          @tickers[market.id] = {
            low:  ticker_init[:min].to_d,
            high: ticker_init[:max].to_d,
            last: ticker_init[:last].to_d,
            open: ticker_init[:first].to_d
          }
          write_h24_key "peatio:#{market.id}:h24:low", @tickers[market.id][:low], at_10_minutes
          write_h24_key "peatio:#{market.id}:h24:high", @tickers[market.id][:high], at_10_minutes
          write_h24_key "peatio:#{market.id}:h24:open", @tickers[market.id][:open], at_10_minutes
        else
          last = trades.first.present? ? trades.first[:price] : ::Trade::ZERO
          @tickers[market.id] = {
            low:  ::Trade::ZERO,
            high: ::Trade::ZERO,
            last: last,
            open: ::Trade::ZERO
          }
        end
        Rails.cache.write "peatio:#{market.id}:ticker", @tickers[market.id]
        Rails.logger.info { "Update ticker for market: #{market.id}, ticker: #{@tickers[market.id]}" }
      end

      private

      def get_market_low(market, trade)
        low_key = "peatio:#{market}:h24:low"
        low = Rails.cache.read(low_key)

        if low.nil?
          ticker_init = Trade.initialize_market_ticker_from_influx(market: trade[:market_id])
          low = ticker_init.blank? ? trade[:price].to_d : ticker_init[:min].to_d
          write_h24_key low_key, low, at_10_minutes
        elsif trade[:price].to_d < low
          low = trade[:price].to_d
          write_h24_key low_key, low
        end

        low
      end

      def get_market_high(market, trade)
        high_key = "peatio:#{market}:h24:high"
        high = Rails.cache.read(high_key)

        if high.nil?
          ticker_init = Trade.market_ticker_from_influx(trade[:market_id])
          high = ticker_init.blank? ? trade[:price].to_d : ticker_init[:max].to_d
          write_h24_key high_key, high, at_10_minutes
        elsif trade[:price].to_d > high
          high = trade[:price].to_d
          write_h24_key high_key, high
        end

        high
      end

      def get_market_open(market, trade)
        open_key = "peatio:#{market}:h24:open"
        open = Rails.cache.read(open_key)
        if open.nil?
          ticker_init = Trade.market_ticker_from_influx(trade[:market_id])
          open = ticker_init.blank? ? trade[:price].to_d : ticker_init[:first].to_d
          write_h24_key open_key, open, at_beginning_of_minute
        end
        open
      end

      def at_beginning_of_minute
        Time.now.at_beginning_of_minute + 1.minute - Time.now
      end

      def at_10_minutes
        Time.now.at_beginning_of_minute + 10.minute - Time.now
      end

      def write_h24_key(key, value, ttl=24.hours)
        Rails.cache.write key, value, expires_in: ttl
      end
    end
  end
end
