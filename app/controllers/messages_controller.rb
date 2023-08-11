class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create] # disabling CSRF protection for this application
  def create
    # all creation logic is covered by message creator service
    render json: MessageCreatorService.call(params)
  end
end
