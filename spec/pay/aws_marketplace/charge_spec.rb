require "spec_helper"

RSpec.describe Pay::AwsMarketplace::Charge do
  fixtures :all

  before do
    @pay_customer = pay_customers(:fake)
    @charge = @pay_customer.charge(10_00)
  end

  it "fake processor api_record" do
    assert_equal @charge, @charge.api_record
    assert_equal "card", @charge.payment_method_type
    assert_equal "Fake", @charge.brand
  end

  it "fake processor refund" do
    assert_nil @charge.amount_refunded
    @charge.refund!
    assert_equal 10_00, @charge.reload.amount_refunded
  end
end
