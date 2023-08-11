require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  test "should create message" do
    assert_difference "PhoneNumber.count", 1 do
      assert_difference "Message.count", 1 do
        post messages_url, params: { phone_number: "1231233211", message_body: "Hello World" }
        assert_response :success
      end
    end
  end
end
