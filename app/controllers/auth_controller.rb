class AuthController < ApplicationController

  def index
    if current_user.has_service?(:linkedin)
      linkedin_connect
      redirect_to auth_callback_path
      return
    end
    request_token = linkedin_client.request_token(:oauth_callback => "http://#{request.host_with_port}/auth/callback")
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret
    redirect_to linkedin_client.request_token.authorize_url
  end

  def callback
    unless current_user.has_service?(:linkedin)
      pin = params[:oauth_verifier]
      atoken, asecret = linkedin_client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
      current_user.save_service_key1(:linkedin, atoken)
      current_user.save_service_key2(:linkedin, asecret)
    else
      linkedin_connect
    end
    @profile = linkedin_client.profile
    @connections = linkedin_client.connections
  end

private

  def linkedin_connect
    linkedin_client.authorize_from_access(current_user.get_service_key1(:linkedin), current_user.get_service_key2(:linkedin))
  end

end




