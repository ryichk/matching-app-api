class Message < ApplicationRecord
  validates :chat_room_id, presence: true
  validates :user_id, presence: true
  validates :content, length: { minimum: 1, maximum: 140 }

  belongs_to :chat_room
  belongs_to :user
end
