require 'spec_helper'

describe MailSafe::AddressReplacer do
  before do
    default_internal_address = /.*@internal\.com/i

    if defined?(MailSafe::Config)
      MailSafe::Config.internal_address_definition = lambda { |addr|
        addr =~ default_internal_address
      }
      MailSafe::Config.replacement_address = "replacement@internal.com"
    end
  end
  describe '#replace_external_addresses' do
    before(:each) do
      @mail = TestMailer.create_test
      MailSafe::AddressReplacer.replace_external_addresses(@mail)
    end

    it "should generate one email using the content's template, and with Sendgrid SMTP headers for each user's info" do

      sendgrid_header = JSON.parse(@mail['X-SMTPAPI'].to_s)
      sendgrid_header['sub']['{username}'].should       == ['internal_1','internal_2']
      sendgrid_header['sub']['{email_address}'].should  == ['internal_1@internal.com', 'internal_2@internal.com']

    end

    it "should create the appropriate postscript including X-SMTPAPI addresses that were removed" do
      postscript = %r(The original recipients were:\s*- to:\s*- donotreply@foobar.com\s*- X_SMTPAPI:\s*- external_1@external.com\s*- external_2@external.com)
      @mail.parts[0].body.should =~ postscript
    end
  end



end
