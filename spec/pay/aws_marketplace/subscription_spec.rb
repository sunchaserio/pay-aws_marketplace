require "spec_helper"
require "aws-sdk-marketplacemetering"
require "aws-sdk-marketplaceentitlementservice"

RSpec.describe Pay::AwsMarketplace::Subscription do
  fixtures :all

  before do
    @pay_customer = pay_customers(:aws_marketplace)
    @subscription = pay_subscriptions(:aws_marketplace)
    assert_equal @pay_customer, @subscription.customer
  end

  it "aws processor subscription" do
    assert_equal @subscription, @subscription.api_record
  end

  it "aws processor cancel" do
    assert_raises Pay::AwsMarketplace::UpdateError do
      @subscription.cancel
    end
  end

  it "aws processor trial period" do
    refute @subscription.on_trial?
  end

  it "aws processor cancel_now!" do
    assert_raises Pay::AwsMarketplace::UpdateError do
      @subscription.cancel_now!
    end
  end

  it "aws processor on_grace_period?" do
    freeze_time do
      @subscription.update(ends_at: 1.week.from_now)
      assert @subscription.on_grace_period?
    end
  end

  it "aws processor resume" do
    assert_raises Pay::AwsMarketplace::UpdateError do
      @subscription.resume
    end
  end

  it "aws processor swap" do
    assert_raises Pay::AwsMarketplace::UpdateError do
      @subscription.swap("another_plan")
    end
  end

  it "aws change quantity" do
    assert_raises Pay::AwsMarketplace::UpdateError do
      @subscription.change_quantity(3)
    end
  end

  it "aws cancel_now! on trial" do
    assert_raises Pay::AwsMarketplace::UpdateError do
      @subscription.cancel_now!
    end
  end

  it "aws nonresumable subscription" do
    @subscription.update(ends_at: 1.week.from_now)
    @subscription.reload

    assert @subscription.on_grace_period?
    assert @subscription.canceled?
    refute @subscription.resumable?
  end

  def entitlement
    OpenStruct.new(
      value: OpenStruct.new(integer_value: 5),
      dimension: "team_ep",
      product_code: "et6zix1m4h3qlfta2qy6r7lnw",
      expiration_date: Time.parse("2024-10-26T13:43:42.608+00:00"),
      customer_identifier: "QzOTBiMmRmN"
    )
  end

  it "aws sync with matching customer record" do
    assert_equal @pay_customer, Pay::AwsMarketplace::Customer.find_by(processor_id: entitlement.customer_identifier)

    Pay::AwsMarketplace::Subscription.sync(entitlement)

    subscription = Pay::AwsMarketplace::Subscription.last
    assert_equal 5, subscription.quantity
    assert_equal "team_ep", subscription.name
  end

  it "aws sync with no matching customer record" do
    @pay_customer.destroy
    assert_nil Pay::AwsMarketplace::Customer.find_by(processor_id: entitlement.customer_identifier)

    assert_raises do
      Pay::AwsMarketplace::Subscription.sync(entitlement)
    end
  end

  it "aws sync with no matching customer record but with object" do
    @pay_customer.update!(processor_id: "abc123")
    assert_nil Pay::AwsMarketplace::Customer.find_by(processor_id: entitlement.customer_identifier)

    Pay::AwsMarketplace::Subscription.sync(entitlement, customer: @pay_customer)

    subscription = Pay::AwsMarketplace::Subscription.last
    assert_equal 5, subscription.quantity
    assert_equal "team_ep", subscription.name
  end

  it "aws sync when subscription already exists" do
    @pay_customer.subscriptions.create!(
      status: :active,
      name: "team_ep",
      processor_plan: "et6zix1m4h3qlfta2qy6r7lnw"
    )

    Pay::AwsMarketplace::Subscription.sync(entitlement)

    subscription = Pay::AwsMarketplace::Subscription.last
    assert_equal 5, subscription.quantity
    assert_equal "team_ep", subscription.name
  end

  describe "aws create from token" do
    before do
      aws_mm = Aws::MarketplaceMetering::Client.new(stub_responses: {
        resolve_customer: {
          customer_aws_account_id: "123456789",
          customer_identifier: "QzOTBiMmRmN",
          product_code: "et6zix1m4h3qlfta2qy6r7lnw"
        }
      })
      expect(Aws::MarketplaceMetering::Client).to receive(:new).and_return(aws_mm)

      aws_mes = Aws::MarketplaceEntitlementService::Client.new(stub_responses: {
        get_entitlements: {
          entitlements: [{
            value: {integer_value: 5},
            dimension: "team_ep",
            product_code: "et6zix1m4h3qlfta2qy6r7lnw",
            expiration_date: Time.parse("2024-10-26T13:43:42.608+00:00"),
            customer_identifier: "QzOTBiMmRmN"
          }],
          next_token: nil
        }
      })
      expect(Aws::MarketplaceEntitlementService::Client).to receive(:new).and_return(aws_mes)
    end

    it "aws sync from registration token" do
      expect {
        Pay::AwsMarketplace::Subscription.create_from_token!("abc123")
      }.to change { Pay::AwsMarketplace::Subscription.last }
    end

    it "aws sync from registration token without customer" do
      Pay::Customer.destroy_all

      expect {
        Pay::AwsMarketplace::Subscription.create_from_token!("abc123")
      }.to change { Pay::AwsMarketplace::Customer.count }
    end
  end

  describe "create usage record" do
    before do
      aws_mm = Aws::MarketplaceMetering::Client.new(stub_responses: {
        batch_meter_usage: {
          results: [],
          unprocessed_records: []
        }
      })
      expect(Aws::MarketplaceMetering::Client).to receive(:new).and_return(aws_mm)
    end

    it "sends an hourly metering record to AWS marketplace" do
      @subscription.create_usage_record(quantity: 10, timestamp: 1.hour.ago)
    end
  end
end
