class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :load_pages
  before_filter :set_timezone
  before_filter :require_login
  helper_method :current_user

  ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| "<span class=\"field_with_errors\">#{html_tag}</span>".html_safe }

  private
  def load_pages
    @pages = PageDecorator.decorate(Page.ordered)
    @top_menu_page = @pages.first || PageDecorator.new(Page.new)
  end

  def set_timezone
    min = request.cookies["time_zone"].to_i
    Time.zone = ActiveSupport::TimeZone[-min.minutes]
  end

  def current_user
    begin
      @current_user ||= UserDecorator.decorate(User.find(session[:username])) if session[:username]
      @current_user ||= UserDecorator.decorate(find_by_remember_me_token(cookies[:remember_me_token])) if cookies[:remember_me_token]
      @current_user ||= UserDecorator.new(User.new)

      @current_user
    rescue
      remove_session
    end
  end

  def find_by_remember_me_token(token)
    user = User.find_by_remember_me_token(token)
    set_session(user) if user.present?
    
    user
  end

  def set_session(user, remember = false)
    session[:user_id] = user.id
    session[:username] = user.username
    REDIS.zincrby "session_metrics:login_counts", 1, user.id
    if remember
      cookies.permanent[:remember_me_token] = user.remember_me_token
    end
  end

  def remove_session
    session[:user_id] = nil
    session[:username] = nil
    cookies.delete :remember_me_token
  end

  def require_login
    not_authenticated unless current_user.signed_in?
  end

  def require_plan
    not_on_plan unless current_user.subscription_active?
  end

  def require_admin
    not_authorized unless current_user.is_admin?
  end

  def not_authenticated
    flash[:warning] = 'Please login or create an account.'
    redirect_to sign_in_path
  end

  def not_on_plan
    flash[:error] = 'You no longer have an active plan. You may choose a new plan if you wish to use the service.'
    redirect_to available_subscription_plans_path
  end

  def not_authorized
    flash[:error] = 'Not Authorized'
    redirect_to current_user.home_path
  end
end
