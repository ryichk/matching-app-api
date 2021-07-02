FactoryBot.define do
  factory :user do
    sequence(:first_name) { |n| "test-first-name#{n}" }
    sequence(:last_name) { |n| "test-last-name#{n}"}
    sequence(:email) { |n| "test#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
