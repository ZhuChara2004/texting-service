# == Schema Information
#
# Table name: phone_numbers
#
#  id         :bigint           not null, primary key
#  number     :string
#  status     :enum             default("active"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  public_id  :uuid
#
# Indexes
#
#  index_phone_numbers_on_number  (number) UNIQUE
#
require "test_helper"

class PhoneNumberTest < ActiveSupport::TestCase
  test "deactivate" do
    phone_number = PhoneNumber.create!(number: 1234567890)
    assert phone_number.status == "active"
    phone_number.deactivate!
    assert phone_number.status == "inactive"
  end
end
