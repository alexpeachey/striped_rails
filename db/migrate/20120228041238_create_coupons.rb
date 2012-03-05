class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :coupon_code
      t.integer :percent_off, default: 0
      t.string :duration
      t.integer :duration_in_months, default: 0
      t.integer :max_redemptions, default: 0
      t.integer :times_redeemed, default: 0
      t.datetime :redeem_by
      t.integer :users_count, default: 0

      t.timestamps
    end
    add_index :coupons, :coupon_code, :unique => true
    add_index :coupons, :redeem_by
  end
end
