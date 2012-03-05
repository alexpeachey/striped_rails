class PasswordResetsController < ApplicationController
  skip_before_filter :require_login

  def new
  end

  def create
    begin
      @user = User.find_by_email(User.sanitize(params[:email]))
      @user.deliver_reset_password_instructions if @user
    rescue
    ensure
      flash[:notice] = 'Instructions have been sent to your email.'
      redirect_to sign_in_path and return
    end
  end

  def edit
    @token = params[:id]
    @user = User.find_by_forgot_password_token(@token)
    not_authorized unless @user
  end

  def update
    @token = params[:token]
    @user = User.find_by_forgot_password_token(@token)
    not_authorized unless @user

    if @user.update_attributes(params[:user])
      remove_session
      redirect_to(sign_in_path, notice: 'Password was successfully updated.')
    else
      flash[:error] = "Error with password reset."
      render action: "edit"
    end
  end
end