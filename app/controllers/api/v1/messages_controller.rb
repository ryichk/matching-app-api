class Api::V1::MessagesController < ApplicationController
  before_action :authenticate_api_v1_user!

  def create
    message = Message.new(message_params)
    if message.save
      render json: {
        status: 200,
        message: message
      }
    else
      render json: {
        status: 500,
        message: 'Error'
      }
    end
  end

  private

  def message_params
    params.permit(:chat_room_id, :user_id, :content)
  end
end
