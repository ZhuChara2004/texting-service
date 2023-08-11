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
class Message < ApplicationRecord
  include AASM

  belongs_to :phone_number

  aasm column: :status, no_direct_assignment: true do
    state :pending, initial: true
    state :delivered, :failed, :invalid

    event :delivered do
      transitions from: :pending, to: :delivered
    end

    event :failed do
      transitions from: :pending, to: :failed
    end

    event :invalid do
      transitions from: :pending, to: :invalid
    end
  end
end
