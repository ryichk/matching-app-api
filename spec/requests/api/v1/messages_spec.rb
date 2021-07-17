require 'rails_helper'

RSpec.describe "Api::V1::Messages", type: :request do
  describe 'POST /create' do
    let(:current_user) { create(:user, gender: 0) }
    let(:other_user) { create(:user, gender: 1) }
    let(:chat_room) { create(:chat_room) }

    before do
      params = {
        email: current_user.email,
        password: current_user.password
      }
      post(api_v1_user_session_path, params: params, as: :json)
      @auth_token = response.headers.slice('client', 'access-token', 'uid')
    end

    context 'success status' do
      it 'send message from current user to other user' do
        params = {
          chat_room_id: chat_room.id,
          user_id: current_user.id,
          content: 'test message'
        }
        aggregate_failures do
          expect {
            post(api_v1_messages_path, params: params, headers: @auth_token)
          }.to change { Message.count }.by(1)
          expect(response).to have_http_status(200)
          response_body = JSON.parse(response.body)
          expect(response_body['status']).to eq(200)
          expect(response_body['message']['chat_room_id']).to eq(chat_room.id)
          expect(response_body['message']['user_id']).to eq(current_user.id)
        end
      end
    end

    context 'error status' do
      it 'send message without token in the request header' do
        params = {
          chat_room_id: chat_room.id,
          user_id: current_user.id,
          content: 'test message'
        }
        post(api_v1_messages_path, params: params)
        response_body = JSON.parse(response.body)
        aggregate_failures do
          expect(response).to have_http_status(401)
          expect(response_body['errors'][0]).to eq('You need to sign in or sign up before continuing.')
        end
      end
    end
  end
end
