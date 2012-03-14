module MailSafe
  class AddressReplacer
    require 'json'
    class << self

      @@replaced_addresses = {}
      @@address_types = ADDRESS_TYPES.dup

      def add_body_postscript_with_mail_header(part, replaced_addresses, call_super = false)
        # we don't want to call add_body_postscript until after we've added the SendGrid SMTPAPI
        # replaced addresses to the list of all addresses replaced by Mail Safe
        @@replaced_addresses.reverse_merge! replaced_addresses
        add_xsmtpapi_to_address_types if replaced_addresses[:X_SMTPAPI]
        if call_super or replaced_addresses[:X_SMTPAPI]
          add_body_postscript_without_mail_header(part, @@replaced_addresses)
        end
        remove_xsmtpapi_from_address_types if replaced_addresses[:X_SMTPAPI]

      end
      alias_method_chain :add_body_postscript, :mail_header


      def replace_external_addresses_with_mail_header(mail)
        replace_external_addresses_without_mail_header(mail)
        # load X-SMTPAPI headers (json)
        x_smtpapi = JSON.parse mail.header['X-SMTPAPI'].to_s

        external_indices = []
        # get a list of indices for external addresses
        if x_smtpapi['to']
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
          add_body_postscript(mail,{:X_SMTPAPI=>deleted_addresses}, true)
        else
          add_body_postscript(mail,{}, true)
        end

        # we need to override add_text_postscript to include sendgrid x-smtpapi and not ADDRESS_TYPES only

      end
      alias_method_chain :replace_external_addresses, :mail_header

      # ADDRESS_TYPES is frozen but we want to add :X_SMTPAPI to it
      # so the original add_[text|html]_postscript functions have
      # the SendGrid specific addresses that MailSafe removed as well
      # when generating their message. Otherwise we would have to
      # override these functions entirely.
      def add_xsmtpapi_to_address_types
        modified_address_types = @@address_types.dup
        modified_address_types << :X_SMTPAPI
        # silence already initialized constant ADDRESS_TYPES
        silence_warnings do
          MailSafe::AddressReplacer.singleton_class.const_set(:ADDRESS_TYPES,modified_address_types.uniq)
        end
      end

      # We then need to reset ADDRESS_TYPES back to the frozen value
      # for MailSafe to be able to process the next message properly
      def remove_xsmtpapi_from_address_types

        # silence already initialized constant ADDRESS_TYPES
        silence_warnings do
          MailSafe::AddressReplacer.singleton_class.const_set(:ADDRESS_TYPES,@@address_types)
          end
      end
    end


  end
end
