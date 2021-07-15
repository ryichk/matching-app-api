class ChatRoom < ApplicationRecord
  has_many :chat_room_users
  has_many :user, through: :chat_room_users
  has_many :messages
end
