require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:current_user) { create(:user, gender: 0) }
  let(:other_user) { create(:user, gender: 1) }
  let(:chat_room) { create(:chat_room) }

  describe 'create successful' do
    context 'valid values' do
      it 'is correct values' do
        message = build(
          :message,
          chat_room_id: chat_room.id,
          user_id: current_user.id,
          content: 'test message'
        )
        expect(message).to be_valid
      end
    end
  end

  describe 'creation failure' do
    context 'blank value' do
      it 'is blank chat_room_id' do
        message = build(
          :message,
          chat_room_id: nil,
          user_id: current_user.id,
          content: 'test message'
        )
        expect(message).to be_invalid
      end

      it 'is blank user_id' do
        message = build(
          :message,
          chat_room_id: chat_room.id,
          user_id: nil,
          content: 'test message'
        )
        expect(message).to be_invalid
      end

      it 'is blank content' do
        message = build(
          :message,
          chat_room_id: chat_room.id,
          user_id: current_user.id,
          content: ''
        )
        expect(message).to be_invalid
      end
    end

    context 'invalid value' do
      it 'is content length of 141 characters' do
        content = (0...140).to_a.join
        message = build(
          :message,
          chat_room_id: chat_room.id,
          user_id: current_user.id,
          content: content
        )
        expect(message).to be_invalid
      end
    end
  end
end
