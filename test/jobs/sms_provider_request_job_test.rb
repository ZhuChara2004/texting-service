# frozen_string_literal: true

require "test_helper"
require 'sidekiq/testing'
Sidekiq::Testing.fake!

class SmsProviderRequestJobTest < ActiveJob::TestCase
  test "sends a POST request with correct body and receives provider's message_id" do
    phone_number = PhoneNumber.create(number: "1112223333")
    message = Message.create(body: "This is test message", phone_number: phone_number)

    callback_url = "#{ENV.fetch("CALLBACK_HOST", "https://example.com")}/messages/delivery_status"
    url = 'https://mock-text-provider.parentsquare.com/provider1'
    expected_body = {
      to_number: phone_number.number,
      message: message.body,
      callback_url:
    }.to_json

    # Stub HTTParty.post to return a message_id
    HTTParty
      .expects(:post)
      .with(url, body: expected_body, headers: { 'Content-Type' => 'application/json' })
      .returns(stub(code: 200, body: { "message_id" => "a09acfb6-8833-46a6-bbd5-2c9cc49241e4" }.to_json))

    perform_enqueued_jobs do
      SmsProviderRequestJob.perform_later(message, url)
    end

    assert_performed_jobs 1
    assert_equal "a09acfb6-8833-46a6-bbd5-2c9cc49241e4", message.reload.provider_id
  end
end
