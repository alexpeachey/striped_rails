class CreditCardsController < ApplicationController
  def new
  end

  def create
    current_user.attributes = params[:user]

    respond_to do |format|
      if current_user.update_credit_card
        format.html { redirect_to profile_path, notice: 'Credit Card was successfully added.' }
        format.json { render json: current_user, status: :created, location: current_user }
      else
        format.html { render action: "new" }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end
end