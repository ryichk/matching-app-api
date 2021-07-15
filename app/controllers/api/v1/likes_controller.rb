class Api::V1::LikesController < ApplicationController
  before_action :authenticate_api_v1_user!

  def index
    render json: {
      status: 200,
      active_likes: current_api_v1_user.active_likes,
      passive_likes: current_api_v1_user.passive_likes
    }
  end

  def create
    @active_like = Like.find_or_initialize_by(like_params)
    unless likes?(@active_like)
      render json: {
        status: 500,
        message: 'Error: 不正ユーザーのためLikeできません。'
      }
      return
    end
    @is_matched = @active_like.matched?
    if @is_matched
      create_like_and_chat_rooms()
      return
    end
    if @active_like.save
      render json: {
        status: 200,
        like: @active_like,
        is_matched: @is_matched
      }
    else
      render json: {
        status: 500,
        message: 'Error: Likeできませんでした。'
      }
    end
  end

  private

  def like_params
    params.permit(:from_user_id, :to_user_id)
  end

  def likes?(active_like)
    if active_like.from_user_id != current_api_v1_user.id || active_like.to_user_id == current_api_v1_user.id
      false
    else
      true
    end
  end

  def create_like_and_chat_rooms
    ChatRoomUser.transaction do
      begin
        @active_like.save!
        chat_room = ChatRoom.create
        ChatRoomUser.find_or_create_by(
          chat_room_id: chat_room.id,
          user_id: @active_like.from_user_id
        )
        ChatRoomUser.find_or_create_by(
          chat_room_id: chat_room.id,
          user_id: @active_like.to_user_id,
        )
        render json: {
          status: 200,
          like: @active_like,
          is_matched: @is_matched
        }
      rescue => exception
        render json: {
          status: 500,
          message: exception.message
        }
      end
    end
  end
end
