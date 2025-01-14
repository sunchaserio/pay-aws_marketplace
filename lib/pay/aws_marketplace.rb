# frozen_string_literal: true

require "pay"
require "aws-sdk-marketplacemetering"
require "aws-sdk-marketplaceentitlementservice"

require "zeitwerk"
Zeitwerk::Loader.for_gem_extension(Pay).tap(&:enable_reloading).setup

require_relative "aws_marketplace/version"

module Pay
  module AwsMarketplace
    class Error < Pay::Error
    end

    class ChargeError < Error
      def initialize(msg = "AWS Marketplace can only charge customer AWS accounts automatically")
        super
      end
    end

    class PaymentMethodError < Error
      def initialize(msg = "AWS Marketplace only allows payment via customer AWS account")
        super
      end
    end

    class UpdateError < Error
      def initialize(msg = "AWS Marketplace agreements can only be changed manually at https://aws.amazon.com/marketplace")
        super
      end
    end
  end
end
