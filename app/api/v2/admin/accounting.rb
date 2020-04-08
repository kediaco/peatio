# frozen_string_literal: true

module API
  module V2
    module Admin
      class Accounting < Grape::API
        desc 'Returns exchange balance sheet'
        get '/balance_sheet' do
          authorize! :read, ::Operations

          assets = ::Operations::Asset.balance
          liabilities = ::Operations::Liability.balance
          balances = assets.merge(liabilities) { |_k, a, b| a - b }
          present({ assets: assets, liabilities: liabilities, balance: balances })
        end
      end
    end
  end
end
