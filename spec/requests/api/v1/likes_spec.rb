require 'rails_helper'

RSpec.describe 'Api::V1::Likes', type: :request do
  let(:male_user) { create(:user, gender: 0) }
  let(:female_user) { create(:user, gender: 1) }
  context 'male user signed in' do
    before do
      params = {
        email: male_user.email,
        password: male_user.password
      }
      post(api_v1_user_session_path, params: params, as: :json)
      @auth_token = response.headers.slice('client', 'access-token', 'uid')
    end

    describe 'GET /index' do
      context 'success status' do
        it 'send with the token of signed-in user in the request header' do
          get(api_v1_likes_path, headers: @auth_token)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response).to have_http_status(200)
            expect(response_body['status']).to eq(200)
          end
        end
      end

      context 'error status' do
        it 'send without token in the request header' do
          get(api_v1_likes_path)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response).to have_http_status(401)
            expect(response_body['errors'][0]).to eq('You need to sign in or sign up before continuing.')
          end
        end
      end
    end

    describe 'POST /create' do
      context 'success status' do
        it 'is when male_user is sending Like to female_user' do
          params = {
            from_user_id: male_user.id,
            to_user_id: female_user.id
          }
          aggregate_failures do
            expect {
              post(api_v1_likes_path, params: params, headers: @auth_token)
            }.to_not change { [ChatRoomUser.count, ChatRoom.count] }
            expect(response).to have_http_status(200)
            response_body = JSON.parse(response.body)
            expect(response_body['status']).to eq(200)
            expect(response_body['like']['from_user_id']).to eq(male_user.id)
            expect(response_body['like']['to_user_id']).to eq(female_user.id)
            expect(response_body['is_matched']).to eq(false)
          end
        end

        it 'is when male_user is sending a Like to female_user and female_user is already sending a Like to male_user' do
          create(:like, from_user_id: female_user.id, to_user_id: male_user.id)
          params = {
            from_user_id: male_user.id,
            to_user_id: female_user.id,
          }
          aggregate_failures do
            expect {
              post(api_v1_likes_path, params: params, headers: @auth_token)
            }.to change { [ChatRoomUser.count, ChatRoom.count] }.by([2, 1])
            expect(response).to have_http_status(200)
            response_body = JSON.parse(response.body)
            expect(response_body['status']).to eq(200)
            expect(response_body['like']['from_user_id']).to eq(male_user.id)
            expect(response_body['like']['to_user_id']).to eq(female_user.id)
            expect(response_body['is_matched']).to eq(true)
          end
        end
      end

      context 'error status' do
        it 'send without token in the request header' do
          params = {
            from_user_id: male_user.id,
            to_user_id: female_user.id
          }
          post(api_v1_likes_path, params: params)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response).to have_http_status(401)
            expect(response_body['errors'][0]).to eq('You need to sign in or sign up before continuing.')
          end
        end

        it 'send without parameters' do
          post(api_v1_likes_path, headers: @auth_token)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response_body['status']).to eq(500)
            expect(response_body['message']).to eq('Error: 不正ユーザーのためLikeできません。')
          end
        end

        it 'is when a user other than the signed-in user likes other user' do
          params = {
            from_user_id: female_user.id,
            to_user_id: male_user.id
          }
          post(api_v1_likes_path, params: params, headers: @auth_token)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response_body['status']).to eq(500)
            expect(response_body['message']).to eq('Error: 不正ユーザーのためLikeできません。')
          end
        end

        it 'is when male user likes myself' do
          params = {
            from_user_id: male_user.id,
            to_user_id: male_user.id
          }
          post(api_v1_likes_path, params: params, headers: @auth_token)
          response_body = JSON.parse(response.body)
          aggregate_failures do
            expect(response_body['status']).to eq(500)
            expect(response_body['message']).to eq('Error: 不正ユーザーのためLikeできません。')
          end
        end
      end
    end
  end
end
