# frozen_string_literal: true

require_relative 'constants'

module Matching
  class Remote

    def initialize(market)
      @id = 0
      @market = market
      @ws_url = 'ws://go-service:8080'
    end

    def ws_connect
      Rails.logger.info { "Websocket connecting to #{@ws_url}" }
      raise "websocket url missing for account #{id}" unless @ws_url

      @ws = Faye::WebSocket::Client.new(@ws_url)

      @ws.on(:open) do |_e|
        subscribe(@ws)
        logger.info { "Websocket connected" }
      end

      @ws.on(:message) do |msg|
        ws_read_message(msg)
      end

      @ws.on(:close) do |e|
        @ws = nil
        @ws_status = false
        Rails.logger.error "Websocket disconnected: #{e.code} Reason: #{e.reason}"
        Fiber.new do
          EM::Synchrony.sleep(WEBSOCKET_CONNECTION_RETRY_DELAY)
          ws_connect
        end.resume
      end
    end

    # > { type: 0, msgid: 1, method: 'subscribe', params: { stream: 'btcusd.trades' } }
    def subscribe(ws)
      streams = ["#{@market}.orders", "#{@market}.trades"]
      streams.each do |s|
        sub = { type: 0, msgid: @id, method: 'subscribe', params: { stream: s } }
        Rails.logger.info 'Open event' + sub.to_s
        EM.next_tick do
          ws.send(JSON.generate(sub))
        end
        @id += 1
      end
    end

    # > { type: 0, msgid: 1, method: "order.create", params: order_params }
    def sumbit(order)
      sub = { type: 0, msgid: @id += 1, method: 'order.create', params: order.as_json }
      EM.next_tick do
        ws.send(JSON.generate(sub))
      end
    end

    # > { type: 0, msgid: 1, method: "order.cancel", params: order_params }
    def cancel(order)
      sub = { type: 0, msgid: @id += 1, method: 'order.create', params: order.as_json }
      EM.next_tick do
        ws.send(JSON.generate(sub))
      end
    end

    # > { type: 1, msgid: 1, method: "order.update", params: order_params }
    # > { type: 1, msgid: 1, method: "order.done", params: order_params }
    # > { type: 1, msgid: 1, method: "trade.create", params: trade_params }
    def ws_read_message(msg)
      Rails.logger.debug {"Received websocket message: #{msg.data}" }

      data = JSON.parse(msg.data)
      # TODO: Parse data recieved from go-service
    end
  end
end
