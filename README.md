# MailSafe Sendgrid

**MailSafe Sendgrid** adds Sendgrid support to Mail Safe by extending MailSafe::AddressReplacer to check for addresses included in the Sendgrid X-SMTPAPI headers. It automatically removes any offending (i.e., non-internal) addresses and removes the corresponding entries from any Sendgrid substitutions. The addresses that are removed are also passed to Mail Safe's postscript message (along with any :to, :cc, and :bcc addresses that were removed by Mail Safe itself).

## Basic usage

If you always want Mail Safe turned on, simply add `mail_safe-sendgrid` to your Gemfile immediately following `mail_safe`.

## Conditional usage
For a more complicated usage case (i.e., you only want `mail_safe` turned on in demo environments and not in production) make sure to add


```ruby
gem "mail_safe", :require => nil
gem "mail_safe-sendgrid", :require => nil
```

to your Gemfile and then manually require `mail_safe` and `mail_safe-sendgrid` after you do your environment checks

```ruby
module MailSafeFilter
  def self.filter_email_addresses(environment = ['development', 'demo', 'staging'])
    if environment.include? Rails.env
      require 'mail_safe'
      require 'mail_safe-sendgrid'
      default_internal_address = /.*@internal\.com/i

      if defined?(MailSafe::Config)
        MailSafe::Config.internal_address_definition = lambda { |addr|
          addr =~ default_internal_address
        }
        MailSafe::Config.replacement_address = "#{Rails.env}_firehose@replacement.com"
      end
    end
  end
end
MailSafeFilter.filter_email_addresses
```

## Tests

All code is tested with [RSpec](https://github.com/rspec/rspec). To run the specs, clone the repository, install the dependencies with `bundle install`, and then run `rake`.

## Issues

If you have any problems or suggestions for the project, please open a GitHub issue.

## License

MailSafe Sendgrid is available under the included MIT license.

## Acknowledgements

Thank you to [Change.org](http://www.change.org/) for sponsoring the project.