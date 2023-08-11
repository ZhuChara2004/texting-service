# frozen_string_literal: true

class SmsProviderRequestJob < ApplicationJob
  queue_as :default

  def perform(message, url = ENV.fetch("SMS_PROVIDER_URL", "https://mock-text-provider.parentsquare.com/provider1"))
    body = {
      to_number: message.phone_number.number,
      message: message.body,
      callback_url: "#{ENV.fetch("CALLBACK_HOST", "https://example.com")}/messages/delivery_status"
    }.to_json

    # body = {to_number: message.phone_number.number, message: message.body, callback_url: "#{ENV.fetch("CALLBACK_HOST", "https://example.com")}/messages/delivery_status" }

    response = HTTParty.post(url, body:, headers: { 'Content-Type' => 'application/json' })

    case response.code
    when 500
      SmsProviderRequestJob.perform_later(message, url)
    else
      message.update!(provider_id: JSON.parse(response.body)["message_id"])
    end
  end
end
