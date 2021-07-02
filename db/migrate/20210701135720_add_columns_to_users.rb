class AddColumnsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :first_name, :string, null: false, after: :name
    add_column :users, :last_name, :string, null: false, after: :first_name
    add_column :users, :gender, :integer, null: false, default: 0, after: :nickname
    add_column :users, :birthday, :date, after: :email
    add_column :users, :profile, :string, limit: 3000, after: :birthday
    add_column :users, :prefecture, :integer, null: false, default: 1, after: :profile

    remove_column :users, :name, :string
  end
end
