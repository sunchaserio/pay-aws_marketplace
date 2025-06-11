require "spec_helper"

RSpec.describe Pay::AwsMarketplace::Customer do
  fixtures :all

  before do
    @pay_customer = pay_customers(:aws_marketplace)
  end

  it "allows aws_marketplace processor" do
    expect {
      users(:none).set_payment_processor :aws_marketplace
    }.to_not raise_error
  end

  it "aws processor api_record" do
    assert_equal @pay_customer.api_record, {customer_identifier: "QzOTBiMmRmN"}
  end

  it "aws processor charge" do
    assert_raises Pay::AwsMarketplace::ChargeError do
      @pay_customer.charge(10_00)
    end
  end

  it "aws processor subscribe" do
    assert_raises Pay::AwsMarketplace::UpdateError do
      @pay_customer.subscribe
    end
  end

  it "aws processor subscribe with promotion code" do
    assert_raises Pay::AwsMarketplace::UpdateError do
      @pay_customer.subscribe(promotion_code: "promo_xxx123")
    end
  end

  it "aws processor add new default payment method" do
    assert_raises Pay::AwsMarketplace::PaymentMethodError do
      @pay_customer.add_payment_method("new", default: true)
    end
  end

  it "aws customer stores aws account id" do
    user = users(:none)
    pay_customer = user.set_payment_processor :aws_marketplace
    assert_nil pay_customer.processor_id
    assert_nil pay_customer.aws_account_id
    pay_customer.update!(processor_id: "bwhUQyJL8sd", aws_account_id: "25404655876")
    assert pay_customer.processor_id
    assert pay_customer.aws_account_id
  end

  it "aws customer update api record" do
    user = users(:none)
    pay_customer = user.set_payment_processor :aws_marketplace

    expect {
      pay_customer.update_api_record(
        "customer_identifier" => "bwhUQyJL8sd",
        "customer_aws_account_id" => "25404655876"
      )
    }.to_not change { pay_customer.reload.api_record }
  end
end
