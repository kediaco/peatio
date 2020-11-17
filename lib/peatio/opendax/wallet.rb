module Opendax
  class Wallet < Peatio::Wallet::Abstract
    DEFAULT_FEATURES = { skip_deposit_collection: false }.freeze
    DEFAULT_ERC20_FEE = { gas_limit: 90_000, gas_price: :standard }.freeze
    GAS_PRICE_THRESHOLDS = %w[standard, safelow, fast].freeze

    def initialize(custom_features = {})
      @features = DEFAULT_FEATURES.merge(custom_features).slice(*SUPPORTED_FEATURES)
      @settings = {}
    end

    def configure(settings = {})
      # Clean client state during configure.
      @client = nil

      @settings.merge!(settings.slice(*SUPPORTED_SETTINGS))

      @wallet = @settings.fetch(:wallet) do
        raise Peatio::Wallet::MissingSettingError, :wallet
      end.slice(:uri, :gateway_url, :address, :secret, :wallet_index)

      @currency = @settings.fetch(:currency) do
       raise Peatio::Wallet::MissingSettingError, :currency
      end.slice(:id, :base_factor, :options)
    end

    def create_address!(options = {})
      # TODO: To define coin type for btc-testnet, btc-mainnet
      response = client.rest_api(:post, '/wallet/new', {
        coin_type: coin_type
      })

      { address: response['address'], secret: response['passphrase'], details: response.except('address', 'secret') }
    rescue Opendax::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    def create_transaction!(transaction, options = {})
      eth_params = coin_type == 'eth' ? eth_transaction(transaction) : {}

      response = client.rest_api(:post, '/tx/send', {
        coin_type:    coin_type,
        to:           transaction.to_address,
        amount:       transaction.amount,
        gateway_url:  wallet_gateway_url,
        wallet_index: wallet_index,
        passphrase:   wallet_secret
      }.merge(eth_params))

      transaction.hash = response['tx']
      transaction
    rescue Opendax::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    def load_balance!
      response = client.rest_api(:post, '/wallet/balance', {
        coin_type:        coin_type,
        gateway_url:      wallet_gateway_url,
        contract_address: erc20_contract_address
      }.compact).fetch('balance')

      if coin_type == 'eth'
        response = response.yield_self { |amount| convert_from_base_unit(amount) }
      end

      response.to_d
    rescue Opendax::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    private

    def eth_transaction(transaction)
      currency_options = @currency.fetch(:options).slice(:gas_limit, :gas_price)
      options = DEFAULT_ERC20_FEE.merge(currency_options)

      if transaction.options.present?
        gas_price = transaction.options[:gas_price]
      else
        gas_speed = options[:gas_price].in?(GAS_PRICE_THRESHOLDS) ? options[:gas_price] : 'standart'
      end

      params = {
        gas_price: gas_price,
        gas_limit: options[:gas_limit],
        gas_speed: gas_speed
      }.compact!

      params.merge!(contract_address: erc20_contract_address) if erc20_contract_address.present?

      params
    end

    def coin_type
      if erc20_contract_address.present?
        'eth'
      else
        currency_id
      end
    end

    def convert_from_base_unit(value)
      value.to_d / @currency.fetch(:base_factor)
    end

    def wallet_secret
      @wallet.fetch(:secret)
    end

    def wallet_index
      @wallet.fetch(:wallet_index)
    end

    def wallet_gateway_url
      @wallet.fetch(:gateway_url)
    end

    def currency_id
      @currency.fetch(:id)
    end

    def erc20_contract_address
      @currency.dig(:options, :erc20_contract_address)
    end

    def client
      @client ||= Client.new(@wallet.fetch(:uri), idle_timeout: 1)
    end
  end
end
