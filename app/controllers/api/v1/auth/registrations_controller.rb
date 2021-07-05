class Api::V1::Auth::RegistrationsController < DeviseTokenAuth::RegistrationsController

  private

  def sign_up_params
    params.permit(:first_name, :last_name, :nickname, :email, :password, :password_confirmation, :gender, :prefecture, :birthday, :image)
  end

  def account_update_params
    params.permit(:nickname, :prefecture, :profile, :image)
  end
end
