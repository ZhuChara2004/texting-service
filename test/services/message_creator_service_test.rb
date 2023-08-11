# frozen_string_literal: true

require "test_helper"

class MessageCreatorServiceTest < ActiveSupport::TestCase
  test "#call creates a phone number, message and runs job" do
    params = {
      phone_number: "1234567890",
      message_body: "Hello World"
    }

    SmsProviderRequestJob
      .expects(:perform_later).once

    assert_difference "PhoneNumber.count", 1 do
      assert_difference "Message.count", 1 do
        result = MessageCreatorService.call(params)
        assert result[:status] == "ok"
        assert result[:message_id].present?
      end
    end
  end

  test "#call creates only one phone number if multiple messages received" do
    message_one_params = {
      phone_number: "1234567890",
      message_body: "Hello World"
    }

    message_two_params = {
      phone_number: "1234567890",
      message_body: "Hello World"
    }

    assert_difference "PhoneNumber.count", 1 do
      assert_difference "Message.count", 2 do
        result1 = MessageCreatorService.call(message_one_params)
        assert result1[:status] == "ok"
        assert result1[:message_id].present?

        result2 = MessageCreatorService.call(message_two_params)
        assert result2[:status] == "ok"
        assert result2[:message_id].present?
      end
    end
  end

  test "#call does not create a message if phone number is inactive" do
    phone_number = PhoneNumber.create!(number: "1234567890")
    phone_number.deactivate!

    SmsProviderRequestJob.expects(:perform_later).never

    params = {
      phone_number: "1234567890",
      message_body: "Hello World"
    }

    assert_no_difference "Message.count" do
      result = MessageCreatorService.call(params)
      assert result[:status] == "error"
      assert result[:message] == "Phone number is inactive"
    end
  end

  test "#call returns exception message if exception is raised" do
    params = {
      phone_number: nil,
      message_body: "Why isn't it working?"
    }

    SmsProviderRequestJob.expects(:perform_later).never

    assert_no_difference "Message.count" do
      result = MessageCreatorService.call(params)
      assert result[:status] == "error"
      assert_includes result[:message], "PG::NotNullViolation"
    end
  end
end