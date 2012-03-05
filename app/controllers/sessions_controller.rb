class SessionsController < ApplicationController
  skip_before_filter :require_login, only: [:new,:create]
  
  def new
  end

  def create
    begin
      user = User.find(User.sanitize(params[:username]))
      if user.authenticate(params[:password])
        set_session(user, params[:remember] == "1")
        redirect_to profile_path, notice: "Signed In!" and return
      else
        flash[:error] = "Invalid username or password"
        render action: "new" and return
      end
    rescue
      flash[:error] = "Invalid username or password"
      render action: "new" and return
    end
  end

  def destroy
    remove_session
    redirect_to root_url, :notice => "Signed out!"
  end
end
