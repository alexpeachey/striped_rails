class UsersController < ApplicationController
  skip_before_filter :require_login, only: [:new,:create]
  before_filter :load_subscription_plans, only: [:new,:create]
  before_filter :require_admin, except: [:new,:create]
  before_filter :hunt_robots, only: [:create]

  def index
    @users = UserDecorator.all

    respond_to do |format|
      format.html
      format.json { render json: @users }
    end
  end

  def show
    @user = UserDecorator.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end

  def new
    @subscription_plan = SubscriptionPlan.find(params[:subscription_plan_id]) if params[:subscription_plan_id]
    @subscription_plan ||= SubscriptionPlan.by_amount.first
    @user = User.new
    @user.subscription_plan = @subscription_plan if @subscription_plan
    
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.create_with_stripe
        set_session(@user, false)
        format.html { redirect_to profile_path, notice: 'Account Created! Welcome to Brand!' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @user = User.find(params[:id])
    @user.is_admin = params[:user].delete(:is_admin)

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private
  def load_subscription_plans
    @subscription_plans = SubscriptionPlanDecorator.decorate(SubscriptionPlan.by_amount)
  end

  def hunt_robots
    if params[:user][:username_confirmation].present? || params[:user][:email_confirmation].present?
      redirect_to sign_up_path
      return false
    end
  end
end
