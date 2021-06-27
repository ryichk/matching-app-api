require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with a name, email, password, and password_confirmation' do
    user = build(:user)
    expect(user).to be_valid
  end

  describe 'is invalid with' do
    specify 'blank name' do
      user = build(:user, name: nil)
      expect(user).to be_invalid
    end

    specify 'blank email' do
      user = build(:user, email: nil)
      expect(user).to be_invalid
    end

    specify 'blank password' do
      user = build(:user, password: nil)
      expect(user).to be_invalid
    end

    skip specify 'blank password confirmation' do
      user = build(:user, password_confirmation: nil)
      expect(user).to be_invalid
    end

    specify 'registered email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).to be_invalid
    end

    specify 'different password and password_confirmation' do
      user = build(:user, password: 'password', password_confirmation: 'passworddiff')
    end
  end
end
