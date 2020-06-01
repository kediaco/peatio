module Jobs
  module Cron
    class AML
      def self.process
        Deposit.aml_processing.each do |d|
          d.source_adresses.each do |address|
            result = Peatio::AML.check!(address, d.currency_id, d.member.uid)
            if result.risk_detected
              d.aml_suspicious!
              break
            end
            break if result.is_pending
          end
          d.process!
        end

        Beneficiary.aml_processing.each do |b|
          result = Peatio::AML.check!(address, b.currency_id, b.member.uid)
          if result.risk_detected
            b.aml_suspicious!
            next
          end
          next if result.is_pending
          b.enable!
        end
        sleep 60
      end
    end
  end
end
