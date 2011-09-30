class AuthController < ApplicationController

  #uncomment the line below if you aren't using bundler
  #require 'rubygems'
  require 'linkedin'

  def index
    # get your api keys at https://www.linkedin.com/secure/developer
    # client = LinkedIn::Client.new("your_api_key", "your_secret")
    # request_token = linkedin_client.request_token(:oauth_callback => 'http://#{request.host_with_port}/auth/callback')

    request_token = linkedin_client.request_token(:oauth_callback => "http://#{request.host_with_port}/auth/callback")
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret
    redirect_to linkedin_client.request_token.authorize_url
  end

  def callback
    # client = LinkedIn::Client.new("your_api_key", "your_secret")
    if session[:atoken].nil?
      pin = params[:oauth_verifier]
      atoken, asecret = linkedin_client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
      session[:atoken] = atoken
      session[:asecret] = asecret
    else
      linkedin_client.authorize_from_access(session[:atoken], session[:asecret])
    end
    @profile = linkedin_client.profile
    @connections = linkedin_client.connections
  end

end
