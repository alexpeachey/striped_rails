class CreateSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :subscription_plans do |t|
      t.string :vault_token
      t.string :name
      t.string :currency
      t.string :interval
      t.integer :amount, default: 0
      t.integer :trial_period_days, default: 0
      t.string :unit_name
      t.integer :included_units, default: 0
      t.integer :overage_price, default: 0
      t.text :description
      t.boolean :unavailable, default: false
      t.integer :users_count, default: 0

      t.timestamps
    end
    add_index :subscription_plans, :vault_token, :unique => true
    add_index :subscription_plans, :amount
    add_index :subscription_plans, :unavailable
  end
end
