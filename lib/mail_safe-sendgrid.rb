module MailSafe
  class AddressReplacer
    require 'json'
    class << self

      @@replaced_addresses = {}
      def add_body_postscript_with_mail_header(part, replaced_addresses, call_super = false)
        @@replaced_addresses.merge! replaced_addresses
        puts @@replaced_addresses
        add_body_postscript_without_mail_header(part, @@replaced_addresses) if call_super

      end
      alias_method_chain :add_body_postscript, :mail_header

      def replace_external_addresses_with_mail_header(mail)
        replace_external_addresses_without_mail_header(mail)
        # load X-SMTPAPI headers (json)
        x_smtpapi = JSON.parse mail.header['X-SMTPAPI'].to_s

        external_indices = []
        # get a list of indices for external addresses
        x_smtpapi['to'].each_with_index do |address, index|
          external_indices << index if !MailSafe::Config.is_internal_address?(address)
        end
        deleted_cnt = 0
        deleted_addresses = []
        external_indices.each do |i|
          # remove any external address from :to
          deleted_addresses << x_smtpapi['to'].delete_at(i - deleted_cnt)
          # remove the related tokens for every array in :sub
          x_smtpapi['sub'].each do |k, v|
            v.delete_at(i-deleted_cnt)
            x_smtpapi['sub'][k] = v
          end
          # the indices decrement as we remove elements, deleted_cnt accounts for this
          deleted_cnt += 1
        end
        # save the headers back to X-SMTPAPI
        mail.header['X-SMTPAPI'].value = x_smtpapi.to_json.gsub(/(["\]}])([,:])(["\[{])/, '\\1\\2 \\3')

        add_body_postscript(mail,{'X_SMTPAPI'=>deleted_addresses}, true)


      end
      alias_method_chain :replace_external_addresses, :mail_header
    end
  end
end
