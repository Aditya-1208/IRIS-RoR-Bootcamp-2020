class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      session[:private_articles_remaining] = user.private_articles_remaining
      redirect_to root_url, notice: 'Logged in!'
    else
      flash[:alert] = 'Email or password is invalid'
      render 'new'
    end
  end

  def destroy
    user = current_user
    user.update(private_articles_remaining: session[:private_articles_remaining])
    session[:user_id] = nil
    session[:private_articles_remaining] = nil
    redirect_to root_url, notice: 'Logged out!'
  end
end