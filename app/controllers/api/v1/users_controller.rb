class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :set_user, only: %i[show]

  def index
    users = User.where(prefecture: current_api_v1_user.prefecture).where.not(gender: current_api_v1_user.gender).order('created_at DESC')
    render json: { status: 200, users: users }
  end

  def show
    render json: { status: 200, user: @user }
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.permit(:first_name, :last_name, :prefecture, :profile, :image)
  end
end
