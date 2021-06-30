require "rails_helper"

RSpec.describe 'Api::V1::Auth::Sessions', type: :request do
  let(:current_user) { create(:user) }
  describe 'POST /api/v1/auth/sign_in' do
    context 'sign in successfully' do
      it 'is correct email and password' do
        params = {
          email: current_user.email,
          password: current_user.password
        }
        post(api_v1_user_session_path, params: params)
        aggregate_failures do
          expect(response).to have_http_status(200)
          expect(response.headers['uid']).to be_present
          expect(response.headers['access-token']).to be_present
          expect(response.headers['client']).to be_present
        end
      end
    end

    context 'sign in failure' do
      it 'is incorrect email' do
        params = {
          email: 'incorrect@example.com',
          password: current_user.password
        }
        post(api_v1_user_session_path, params: params)
        response_body = JSON.parse(response.body)
        aggregate_failures do
          expect(response).to have_http_status(401)
          expect(response.headers['uid']).to be_blank
          expect(response.headers['access-token']).to be_blank
          expect(response.headers['client']).to be_blank
          expect(response_body['success']).to be_falsey
          expect(response_body['errors']).to include('Invalid login credentials. Please try again.')
        end
      end

      it 'is incorrect password' do
        params = {
          email: current_user.email,
          password: 'incorrect-password'
        }
        post(api_v1_user_session_path, params: params)
        response_body = JSON.parse(response.body)
        aggregate_failures do
          expect(response).to have_http_status(401)
          expect(response.headers['uid']).to be_blank
          expect(response.headers['access-token']).to be_blank
          expect(response.headers['client']).to be_blank
          expect(response_body['success']).to be_falsey
          expect(response_body['errors']).to include('Invalid login credentials. Please try again.')
        end
      end
    end
  end

  describe 'DELETE /api/v1/auth/sign_out' do
    it 'is able to sign out' do
      headers = current_user.create_new_auth_token
      delete(destroy_api_v1_user_session_path, headers: headers)
      response_body = JSON.parse(response.body)
      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response_body['success']).to be_truthy
        expect(current_user.reload.tokens).to be_blank
      end
    end
  end
end
