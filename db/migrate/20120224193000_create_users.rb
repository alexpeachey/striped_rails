class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_digest
      t.string :email
      t.string :full_name
      t.string :vault_token
      t.references :subscription_plan
      t.references :coupon
      t.boolean :is_admin, default: false

      t.timestamps
    end
    add_index :users, :username, :unique => true
    add_index :users, :email, :unique => true
    add_index :users, :subscription_plan_id
    add_index :users, :coupon_id
    add_index :users, :vault_token
    add_index :users, :created_at
  end
end
