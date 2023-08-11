# == Schema Information
#
# Table name: phone_numbers
#
#  id         :bigint           not null, primary key
#  number     :string           not null
#  status     :enum             default("active"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  public_id  :uuid             not null
#
# Indexes
#
#  index_phone_numbers_on_number  (number) UNIQUE
#
class PhoneNumber < ApplicationRecord
  STATUSES = {
    active: "active",
    inactive: "inactive"
  }.freeze

  has_many :messages, dependent: :destroy

  def deactivate!
    update!(status: STATUSES[:inactive])
  end

  def inactive?
    status == STATUSES[:inactive]
  end
end
