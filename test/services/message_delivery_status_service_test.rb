# frozen_string_literal: true

require "test_helper"

class MessageDeliveryStatusServiceTest < ActiveSupport::TestCase
  test "#call updates message status to delivered" do
    message = Message.create!(
      body: "Hello World",
      provider_id: SecureRandom.uuid,
      phone_number: PhoneNumber.create!(number: "1234567890")
    )

    result = MessageDeliveryStatusService.call(status: "delivered", message_id: message.provider_id)

    assert result[:status] == "ok"
    assert message.reload.delivered?
  end

  test "#call updates message status to failed" do
    message = Message.create!(
      body: "Hello World",
      provider_id: SecureRandom.uuid,
      phone_number: PhoneNumber.create!(number: "1234567890")
    )

    result = MessageDeliveryStatusService.call(status: "failed", message_id: message.provider_id)

    assert result[:status] == "ok"
    assert message.reload.failed?
  end

  test "#call updates message status to invalid" do
    message = Message.create!(
      body: "Hello World",
      provider_id: SecureRandom.uuid,
      phone_number: PhoneNumber.create!(number: "1234567890")
    )

    result = MessageDeliveryStatusService.call(status: "invalid", message_id: message.provider_id)

    assert result[:status] == "ok"
    assert message.reload.invalid?
    assert message.phone_number.inactive?
  end

  test "#call returns status error if invalid status" do
    message = Message.create!(
      body: "Hello World",
      provider_id: SecureRandom.uuid,
      phone_number: PhoneNumber.create!(number: "1234567890")
    )

    expected_result = { status: "error", message: "Invalid status" }

    assert_equal(
      expected_result,
      MessageDeliveryStatusService.call(status: "invalid_status", message_id: message.provider_id)
    )
  end

  test "#call returns unexpected error" do
    response = MessageDeliveryStatusService.call(status: 'delivered', message_id: 'nonexistent')

    assert_equal 'error', response[:status]
    assert_match /undefined method/, response[:message]
  end
end
