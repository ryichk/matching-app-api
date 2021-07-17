require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'creation successful' do
    context 'valid values' do
      it 'is correct first_name, last_name, email, password and password_confirmation' do
        user = build(:user)
        expect(user).to be_valid
      end

      it 'is password length of 8 characters' do
        user = build(:user, password: 'password', password_confirmation: 'password')
        expect(user).to be_valid
      end

      it 'is password length of 32 characters' do
        user = build(:user, password: 'passwordpasswordpasswordpassword', password_confirmation: 'passwordpasswordpasswordpassword')
        expect(user).to be_valid
      end
    end
  end

  describe 'creation failure' do
    context 'blank value' do
      it 'is blank first name' do
        user = build(:user, first_name: nil)
        expect(user).to be_invalid
      end

      it 'is blank last name' do
        user = build(:user, last_name: nil)
        expect(user).to be_invalid
      end

      it 'is blank nickname' do
        user = build(:user, nickname: nil)
        expect(user).to be_invalid
      end

      it 'is blank email' do
        user = build(:user, email: nil)
        expect(user).to be_invalid
      end

      it 'is blank password' do
        user = build(:user, password: nil)
        expect(user).to be_invalid
      end

      it 'is blank gender' do
        user = build(:user, gender: nil)
        expect(user).to be_invalid
      end

      it 'is blank prefecture' do
        user = build(:user, prefecture: nil)
        expect(user).to be_invalid
      end
    end

    context 'invalid value' do
      it 'is password length of 7 characters' do
        password = (0...6).to_a.join
        user = build(:user, password: password, password_confirmation: 'passwor')
        expect(user).to be_invalid
      end

      it 'is password length of 33 characters' do
        password = (0...32).to_a.join
        user = build(:user, password: password, password_confirmation: 'passwordpasswordpasswordpasswordp')
        expect(user).to be_invalid
      end

      it 'is registered email' do
        create(:user, email: 'test@example.com')
        user = build(:user, email: 'test@example.com')
        expect(user).to be_invalid
      end

      it 'is different password and password_confirmation' do
        user = build(:user, password: 'password', password_confirmation: 'diffpassword')
        expect(user).to be_invalid
      end
    end
  end
end
