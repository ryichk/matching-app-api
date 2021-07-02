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
end

