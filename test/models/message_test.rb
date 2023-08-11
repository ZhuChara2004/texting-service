# == Schema Information
#
# Table name: messages
#
#  id              :bigint           not null, primary key
#  body            :string
#  status          :enum             default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  phone_number_id :bigint           not null
#  public_id       :uuid             not null
#
# Indexes
#
#  index_messages_on_phone_number_id  (phone_number_id)
#  index_messages_on_public_id        (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (phone_number_id => phone_numbers.id)
#
require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "delivered! transitions from pending to delivered" do
    message = messages(:pending)
    message.delivered!
    assert_equal "delivered", message.status
  end

  test "failed! transitions from pending to failed" do
    message = messages(:pending)
    message.failed!
    assert_equal "failed", message.status
  end

  test "invalid! transitions from pending to invalid" do
    message = messages(:pending)
    message.invalid!
    assert_equal "invalid", message.status
  end
end
