class ApplicationController < ActionController::Base
  helper_method :current_user
  def current_ability
    @current_ability ||= Ability.new(current_user, session)
  end
  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      @current_user = nil
    end
  end

end