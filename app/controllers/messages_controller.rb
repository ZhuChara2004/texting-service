class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :delivery_status] # disabling CSRF protection for this application
  def create
    # all creation logic is covered by message creator service
    render json: MessageCreatorService.call(params)
  end

  def delivery_status
    puts params
    # render json: MessageDeliveryStatusService.call(params)
  end
end
