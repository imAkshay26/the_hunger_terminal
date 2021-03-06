class SendOrderMailJob < ApplicationJob
  queue_as :default

  def perform(terminal_id, orders, message, company_id)
    OrderMailer.send_mail_to_terminal(terminal_id, orders, message, company_id).deliver_later
  end
end
