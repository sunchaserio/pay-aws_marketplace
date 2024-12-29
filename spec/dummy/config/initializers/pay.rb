Pay.setup do |config|
  config.enabled_processors = [:aws_marketplace]
  # For use in the receipt/refund/renewal mailers
  config.business_name = "Test Business"
  config.business_address = "1600 Pennsylvania Avenue NW\nWashington, DC 20500"
  config.application_name = "My App"
  config.support_email = "support@example.org"
end
