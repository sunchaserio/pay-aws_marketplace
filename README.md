# Pay::AwsMarketplace

Add support for AWS Marketplace customers to the Pay gem.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add pay-aws_marketplace
```

## Usage

Use the `Pay::AwsMarketplace::Subscription.sync_from_customer_token` method to set up new customers when AWS Marketplace redirects them to your application after a purchase.

Use `Pay::AwsMarketplace::Subscription.sync` to update a subscription from AWS Marketplace, for example to find out of a subscription has been cancelled, expired, renewed, or changed quantities.

## Development

Run `bundle config local.pay-aws_marketplace ~/path/to/checkout` in your application to use the code in your checked out repo.

Run `bin/rspec` to run the tests.

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/indirect/pay-aws_marketplace. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/indirect/pay-aws_marketplace/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Pay::AwsMarketplace project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/indirect/pay-aws_marketplace/blob/main/CODE_OF_CONDUCT.md).
