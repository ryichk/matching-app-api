require 'rails_helper'

RSpec.describe 'Api::V1::ChatRooms', type: :request do
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

  describe 'GET /index' do
    context 'success status' do
      it 'have no chat rooms' do
        get(api_v1_chat_rooms_path, headers: @auth_token)
        response_body = JSON.parse(response.body)
        aggregate_failures do
          expect(response).to have_http_status(200)
          expect(response_body['status']).to eq(200)
          expect(response_body['chat_rooms'].length).to eq(0)
        end
      end

      it 'have one chat room and last message' do
        create(:like, from_user_id: other_user.id, to_user_id: current_user.id)
        create(:like, from_user_id: current_user.id, to_user_id: other_user.id)
        create(:chat_room_user, chat_room_id: chat_room.id, user_id: current_user.id)
        create(:chat_room_user, chat_room_id: chat_room.id, user_id: other_user.id)
        create(:message, chat_room_id: chat_room.id, user_id: other_user.id, content: 'test message!')

        get(api_v1_chat_rooms_path, headers: @auth_token)
        response_body = JSON.parse(response.body)
        aggregate_failures do
          expect(response).to have_http_status(200)
          expect(response_body['status']).to eq(200)
          expect(response_body['chat_rooms'].length).to eq(1)
          expect(response_body['chat_rooms'][0]['chat_room']['id']).to eq(chat_room.id)
          expect(response_body['chat_rooms'][0]['other_user']['id']).to eq(other_user.id)
          expect(response_body['chat_rooms'][0]['last_message']['chat_room_id']).to eq(chat_room.id)
          expect(response_body['chat_rooms'][0]['last_message']['user_id']).to eq(other_user.id)
          expect(response_body['chat_rooms'][0]['last_message']['content']).to eq('test message!')
        end
      end
    end

    context 'error status' do
      it 'send without token in the request header' do
        get(api_v1_chat_rooms_path)
        response_body = JSON.parse(response.body)
        aggregate_failures do
          expect(response).to have_http_status(401)
          expect(response_body['errors'][0]).to eq('You need to sign in or sign up before continuing.')
        end
      end
    end
  end

  describe 'GET /show' do
    context 'success status' do
      it 'have no messages' do
        create(:like, from_user_id: other_user.id, to_user_id: current_user.id)
        create(:like, from_user_id: current_user.id, to_user_id: other_user.id)
        create(:chat_room_user, chat_room_id: chat_room.id, user_id: current_user.id)
        create(:chat_room_user, chat_room_id: chat_room.id, user_id: other_user.id)

        get("/api/v1/chat_rooms/#{chat_room.id}", headers: @auth_token)
        response_body = JSON.parse(response.body)
        aggregate_failures do
          expect(response).to have_http_status(200)
          expect(response_body['status']).to eq(200)
          expect(response_body['messages'].length).to eq(0)
          expect(response_body['other_user']['id']).to eq(other_user.id)
        end
      end

      it 'have two messages' do
        create(:like, from_user_id: other_user.id, to_user_id: current_user.id)
        create(:like, from_user_id: current_user.id, to_user_id: other_user.id)
        create(:chat_room_user, chat_room_id: chat_room.id, user_id: current_user.id)
        create(:chat_room_user, chat_room_id: chat_room.id, user_id: other_user.id)
        create(:message, chat_room_id: chat_room.id, user_id: current_user.id, content: 'test message!!')
        create(:message, chat_room_id: chat_room.id, user_id: other_user.id, content: 'test message!!!')

        get("/api/v1/chat_rooms/#{chat_room.id}", headers: @auth_token)
        response_body = JSON.parse(response.body)
        aggregate_failures do
          expect(response).to have_http_status(200)
          expect(response_body['status']).to eq(200)
          expect(response_body['messages'].length).to eq(2)
          expect(response_body['messages'][0]['chat_room_id']).to eq(chat_room.id)
          expect(response_body['messages'][0]['user_id']).to eq(current_user.id)
          expect(response_body['messages'][0]['content']).to eq('test message!!')
          expect(response_body['messages'][1]['chat_room_id']).to eq(chat_room.id)
          expect(response_body['messages'][1]['user_id']).to eq(other_user.id)
          expect(response_body['messages'][1]['content']).to eq('test message!!!')
          expect(response_body['other_user']['id']).to eq(other_user.id)
        end
      end
    end

    context 'error status' do
      it 'send without token in the request header' do
        get("/api/v1/chat_rooms/#{chat_room.id}")
        response_body = JSON.parse(response.body)
        aggregate_failures do
          expect(response).to have_http_status(401)
          expect(response_body['errors'][0]).to eq('You need to sign in or sign up before continuing.')
        end
      end
    end
  end
end
