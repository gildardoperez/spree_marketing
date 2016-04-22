class ListModificationJob < ActiveJob::Base
  queue_as :default

  # rescue_from(Gibbon::MailChimpError) do |exception|
  # end

  def perform(list, emails, list_type = nil)
    gibbon_service = GibbonService.new(list.uid)
    contacts_data = gibbon_service.update_list(emails)
    list.contacts_lists.destroy_all
    contacts_data.each do |contact_data|
      list.contacts << Spree::Contact.build(email: contact_data['email_address'],
                                            uid: contact_data['id'],
                                            mailchimp_id: contact_data['unique_email_id'])
    end
    list.save
  end
end
