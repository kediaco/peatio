# encoding: UTF-8
# frozen_string_literal: true

class Refund < ApplicationRecord
  extend Enumerize
  include AASM
  include AASM::Locking

  STATES = { pending: 0, processed: 100, failed: -100 }.freeze

  belongs_to :deposit, required: true

  aasm whiny_transitions: false do
    state :pending, initial: true
    state :processed
    state :failed

    event :process do
      transitions from: :pending, to: :processed do
        transaction = process_refund!
      end
    end

    event :fail do
      transitions from: :processed, to: :failed
    end
  end

  def process_refund!
    WalletService.new(Wallet.deposit.find_by(currency: deposit.currency)).refund!(self)
  end
end
