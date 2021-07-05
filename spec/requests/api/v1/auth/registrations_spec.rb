require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Registrations', type: :request do
  describe 'POST /api/v1/auth' do
    context 'success status' do
      it 'is correct values' do
        params = attributes_for(:user)
        post(api_v1_user_registration_path, params: params)
        response_body = JSON.parse(response.body)
        aggregate_failures do
          expect(response).to have_http_status(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(User.last.id)
          expect(response_body['data']['first_name']).to eq(User.last.first_name)
          expect(response_body['data']['last_name']).to eq(User.last.last_name)
          expect(response_body['data']['email']).to eq(User.last.email)
          expect(response_body['data']['password']).to eq(User.last.password)
        end
      end

      it 'is same value password and password_confirmation' do
        params = attributes_for(:user, password: 'samepassword', password_confirmation: 'samepassword')
        post(api_v1_user_registration_path, params: params)
        response_body = JSON.parse(response.body)
        aggregate_failures do
          expect(response).to have_http_status(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(User.last.id)
          expect(response_body['data']['first_name']).to eq(User.last.first_name)
          expect(response_body['data']['last_name']).to eq(User.last.last_name)
          expect(response_body['data']['email']).to eq(User.last.email)
          expect(response_body['data']['password']).to eq(User.last.password)
        end
      end
    end

    context 'error status' do
      it 'is blank password_confirmation value' do
        params = attributes_for(:user, password_confirmation: '')
        post(api_v1_user_registration_path, params: params)
        response_body = JSON.parse(response.body)
        aggregate_failures do
          expect(response).to have_http_status(422)
          expect(response_body['status']).to eq('error')
          expect(response_body['errors']['full_messages']).to include("Password confirmation doesn't match Password")
        end
      end
    end
  end

  describe 'PUT /api/v1/auth' do
    let(:current_user) { create(:user) }
    context 'user signed in' do
      before do
        params = {
          email: current_user.email,
          password: current_user.password
        }
        post(api_v1_user_session_path, params: params, as: :json)
        @auth_token = response.headers.slice('client', 'access-token', 'uid')
      end

      context 'success status' do
        it 'update nickname' do
          params = { nickname: 'update nickname' }
          put(api_v1_user_registration_path, params: params, headers: @auth_token)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response).to have_http_status(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data']['nickname']).not_to eq(current_user.nickname)
            expect(response_body['data']['nickname']).to eq('update nickname')
            expect(response_body['data']['prefecture']).to eq(current_user.prefecture)
            expect(response_body['data']['profile']).to eq(current_user.profile)
          end
        end

        it 'update prefecture' do
          params = { prefecture: 2 }
          put(api_v1_user_registration_path, params: params, headers: @auth_token)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response).to have_http_status(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data']['nickname']).to eq(current_user.nickname)
            expect(response_body['data']['prefecture']).not_to eq(current_user.prefecture)
            expect(response_body['data']['prefecture']).to eq(2)
            expect(response_body['data']['profile']).to eq(current_user.profile)
          end
        end

        it 'update profile' do
          params = { profile: 'update profile' }
          put(api_v1_user_registration_path, params: params, headers: @auth_token)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response).to have_http_status(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data']['nickname']).to eq(current_user.nickname)
            expect(response_body['data']['prefecture']).to eq(current_user.prefecture)
            expect(response_body['data']['profile']).not_to eq(current_user.prefecture)
            expect(response_body['data']['profile']).to eq('update profile')
          end
        end

        it 'update nickname, prefecture and profile' do
          params = { nickname: 'update nickname2', prefecture: 2, profile: 'update profile2' }
          put(api_v1_user_registration_path, params: params, headers: @auth_token)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response).to have_http_status(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data']['nickname']).not_to eq(current_user.nickname)
            expect(response_body['data']['nickname']).to eq('update nickname2')
            expect(response_body['data']['prefecture']).not_to eq(current_user.prefecture)
            expect(response_body['data']['prefecture']).to eq(2)
            expect(response_body['data']['profile']).not_to eq(current_user.profile)
            expect(response_body['data']['profile']).to eq('update profile2')
          end
        end
      end

      context 'error status' do
        it 'update first name' do
          params = { first_name: 'update first name' }
          put(api_v1_user_registration_path, params: params, headers: @auth_token)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response).to have_http_status(422)
            expect(response_body['status']).to eq('error')
            expect(response_body['errors']).to include('Please submit proper account update data in request body.')
          end
        end

        it 'update last name' do
          params = { last_name: 'update last name' }
          put(api_v1_user_registration_path, params: params, headers: @auth_token)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response).to have_http_status(422)
            expect(response_body['status']).to eq('error')
            expect(response_body['errors']).to include('Please submit proper account update data in request body.')
          end
        end

        it 'update gender' do
          params = { gender: 2 }
          put(api_v1_user_registration_path, params: params, headers: @auth_token)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response).to have_http_status(422)
            expect(response_body['status']).to eq('error')
            expect(response_body['errors']).to include('Please submit proper account update data in request body.')
          end
        end

        it 'update email' do
          params = { email: 'update@test.com' }
          put(api_v1_user_registration_path, params: params, headers: @auth_token)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response).to have_http_status(422)
            expect(response_body['status']).to eq('error')
            expect(response_body['errors']).to include('Please submit proper account update data in request body.')
          end
        end

        it 'update password' do
          params = { password: 'update password' }
          put(api_v1_user_registration_path, params: params, headers: @auth_token)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response).to have_http_status(422)
            expect(response_body['status']).to eq('error')
            expect(response_body['errors']).to include('Please submit proper account update data in request body.')
          end
        end

        it 'update birthday' do
          params = { birthday: '2021-07-06T00:00:00' }
          put(api_v1_user_registration_path, params: params, headers: @auth_token)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response).to have_http_status(422)
            expect(response_body['status']).to eq('error')
            expect(response_body['errors']).to include('Please submit proper account update data in request body.')
          end
        end
      end
    end

    context 'user not signed in' do
      context 'error status' do
        it 'update nickname, prefecture and profile' do
          params = { nickname: 'update nickname', prefecture: 2, profile: 'update profile' }
          put(api_v1_user_registration_path, params: params)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response).to have_http_status(404)
            expect(response_body['status']).to eq('error')
            expect(response_body['errors']).to include('User not found.')
          end
        end
      end
    end
  end
end
