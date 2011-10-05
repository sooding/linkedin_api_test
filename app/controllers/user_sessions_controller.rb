class UserSessionsController < ApplicationController

  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_to root_path
    else
      flash[:error] = @user_session.errors.full_messages.join('<br/ >').html_safe
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    session[:profile] = nil
    redirect_to root_path
  end

end

