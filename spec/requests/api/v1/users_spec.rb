require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
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

    describe 'GET /index' do
      it 'is success status' do
        get(api_v1_users_path, headers: @auth_token)
        response_body = JSON.parse(response.body)
        aggregate_failures do
          expect(response).to have_http_status(200)
          expect(response_body['status']).to eq(200)
        end
      end
    end

    describe 'GET /show' do
      it 'is success status' do
        get("/api/v1/users/#{current_user.id}", headers: @auth_token)
        response_body = JSON.parse(response.body)
        aggregate_failures do
          expect(response).to have_http_status(200)
          expect(response_body['status']).to eq(200)
        end
      end
    end
  end

  context 'user not signed in' do
    describe 'GET /index' do
      it 'is error status' do
        get(api_v1_users_path)
        expect(response).to have_http_status(401)
      end
    end

    describe 'GET /show' do
      it 'is error status' do
        get("/api/v1/users/#{current_user.id}")
        expect(response).to have_http_status(401)
      end
    end
  end
end
