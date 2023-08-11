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
#  public_id       :uuid
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
  belongs_to :phone_number
end
