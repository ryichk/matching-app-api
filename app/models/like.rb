class Like < ApplicationRecord
  belongs_to :to_user, class_name: 'User', foreign_key: :to_user_id
  belongs_to :from_user, class_name: 'User', foreign_key: :from_user_id

  def matched?
    if Like.find_by(
      from_user_id: to_user_id,
      to_user_id: from_user_id
    )
      true
    else
      false
    end
  end
end
