# frozen_string_literal: true

class MessageDeliveryStatusService
  def initialize(params)
    @params = params
  end

  def self.call(params)
    new(params).call
  end

  def call
    case @params[:status]
    when "delivered"
      message_object.delivered!
    when "failed"
      message_object.failed!
    when "invalid"
      message_object.invalid!
      message_object.phone_number.deactivate!
    else
      raise "Invalid status"
    end
    {
      status: "ok",
      message: {
        phone_number: message_object.phone_number.number,
        body: message_object.body,
      }
    }
  rescue => e
    {
      status: "error",
      message: e.message
    }
  end

  private

  def message_object
    Message.find_by(provider_id: @params[:message_id])
  end
end
