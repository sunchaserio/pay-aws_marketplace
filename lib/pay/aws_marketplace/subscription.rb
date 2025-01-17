module Pay
  module AwsMarketplace
    class Subscription < Pay::Subscription
      def self.sync_from_token!(token, owner: nil)
        aws_mm = Aws::MarketplaceMetering::Client.new(region: "us-east-1")
        customer_info = aws_mm.resolve_customer(registration_token: token)

        customer = Customer.create_with(
          aws_account_id: customer_info.customer_aws_account_id,
          owner: owner
        ).find_or_create_by!(
          processor: "aws_marketplace",
          processor_id: customer_info.customer_identifier
        )

        aws_mes = Aws::MarketplaceEntitlementService::Client.new(region: "us-east-1")
        entitlement = aws_mes.get_entitlements(
          product_code: customer_info.product_code,
          filter: {CUSTOMER_IDENTIFIER: [customer_info.customer_identifier]},
          max_results: 1
        ).entitlements.first

        sync(entitlement, customer: customer)
      end

      def self.sync(entitlement, customer: nil)
        customer ||= Customer.find_by(processor_id: entitlement.customer_identifier)

        unless customer
          raise Pay::Error, "Customer with processor_id #{entitlement.customer_identifier} missing while syncing"
        end

        status = :active
        ends_at = nil

        # Pay uses `ends_at` to track the time an already-scheduled cancellation request should take
        # effect.  Amazon uses `expiration_date` to tell us when the contracted subscription period
        # will end. As a result, we have to calculate the current status of the sub ourselves and
        # put that into `status`.
        if entitlement.expiration_date < Time.current
          status = :cancelled
          ends_at = entitlement.expiration_date.utc
        end

        customer.subscriptions.find_or_initialize_by(
          processor_plan: entitlement.product_code
        ).tap do |sub|
          sub.update!(
            name: entitlement.dimension,
            quantity: entitlement.value.integer_value,
            ends_at: ends_at,
            current_period_end: entitlement.expiration_date.utc,
            status: status,
            data: {entitlement: entitlement.to_h}
          )
        end
      end

      # AWS Marketplace Entitlements don't have IDs, but the marketplace does enforce a unique
      # constraint per customer for each product. You can't subscribe to one product twice.
      before_validation -> { self[:processor_id] ||= [processor_plan, customer_id].join("-") }

      def api_record(**options)
        self
      end

      def cancel(**options)
        raise UpdateError
      end

      def cancel_now!(**options)
        raise UpdateError
      end

      def paused?
        status == "paused"
      end

      def pause
        raise UpdateError
      end

      def resumable?
        false
      end

      def resume
        raise UpdateError
      end

      def swap(plan, **options)
        raise UpdateError
      end

      def change_quantity(quantity, **options)
        raise UpdateError
      end

      def retry_failed_payment
        raise ChargeError
      end

      def create_usage_record(quantity:, timestamp: Time.now)
        Aws::MarketplaceMetering::Client.new(region: "us-east-1").batch_meter_usage(
          product_code: processor_plan,
          usage_records: [{
            customer_identifier: customer.processor_id,
            dimension: name,
            quantity: quantity,
            timestamp: timestamp
          }]
        )
      end

      def entitlement_quantity
        data&.dig("entitlement", "value", "integer_value").to_i
      end
    end
  end
end
