$:.unshift(File.expand_path("../../lib", __FILE__))
require 'rubygems'
require 'mail_safe'
require 'sendgrid'
require 'mail_safe-sendgrid'
require 'action_mailer'
require 'json'

class TestMailer < ActionMailer::Base
  include SendGrid
  public
  def create_test
    user_data = [
      {:email_address =>'external_1@external.com', :name =>'external_1'},
      {:email_address =>'external_2@external.com', :name =>'external_2'},
      {:email_address =>'internal_1@internal.com', :name =>'internal_1'},
      {:email_address =>'internal_2@internal.com', :name =>'internal_2'}
    ]
    subject = 'Test'
    content = 'This is a test email.'

    email_addresses, usernames = transpose_user_data(user_data)

    sendgrid_recipients email_addresses
    sendgrid_substitute '{username}', usernames
    sendgrid_substitute '{email_address}', email_addresses
    sendgrid_category   'Test Email'

    mail(:to => 'donotreply@foobar.com', :from => 'donotreply@foobar.com', :subject  => subject) do |format|
      format.text { render :text => content }
      format.html { render :text => content }
    end
  end

  def transpose_user_data(user_data)
    user_data.collect { |u| [ u[:email_address], u[:name]] }.transpose
  end

end


