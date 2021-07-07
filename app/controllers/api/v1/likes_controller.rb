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
    active_like = Like.find_or_initialize_by(like_params)
    if active_like.from_user_id != current_api_v1_user.id
      render json: {
        status: 500,
        message: 'Error: 不正ユーザーのためLikeできません。'
      }
      return
    elsif active_like.to_user_id == current_api_v1_user.id
      render json: {
        status: 500,
        message: 'Error: 自分をLikeすることはできません。'
      }
      return
    end

    if active_like.save
      render json: {
        status: 200,
        like: active_like
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
end
