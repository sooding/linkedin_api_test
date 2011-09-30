require 'oauth/controllers/consumer_controller'

class OauthConsumersController < ApplicationController
  include Oauth::Controllers::ConsumerController

  # Replace this with the equivalent for your authentication framework
  # Eg. for devise
  #
  #   before_filter :authenticate_user!, :only=>:index
  #before_filter :login_required, :only => :index

  def index
    @consumer_tokens = ConsumerToken.all :conditions => {:user_id => current_user.id }
    @services = OAUTH_CREDENTIALS.keys - @consumer_tokens.collect { |c| c.class.service_name }
  end

  def callback
  	super
  end

  #def client
  #  super
  #end
  def client
    method = request.method.downcase.to_sym
    path = "/#{params[:endpoint]}?#{request.query_string}"
    if consumer_credentials[:expose]
      if @token
        oauth_response = @token.client.send(method, path)
        if oauth_response.is_a? Net::HTTPRedirection
          # follow redirect
          oauth_response = @token.client.send(method, oauth_response['Location'])
        end
        #render :text => oauth_response.body
        render :xml => oauth_response.body
      else
        render :text => "Token needed.", :status => 403
      end
    else
      render :text => "Not allowed", :status => 403
    end
  end


  protected

  # Change this to decide where you want to redirect user to after callback is finished.
  # params[:id] holds the service name so you could use this to redirect to various parts
  # of your application depending on what service you're connecting to.
  def go_back
    redirect_to root_url
  end

  # The plugin requires logged_in? to return true or false if the user is logged in. Uncomment and
  # call your auth frameworks equivalent below if different. eg. for devise:
  #
  def logged_in?
    current_user
  end

  # The plugin requires current_user to return the current logged in user. Uncomment and
  # call your auth frameworks equivalent below if different.
  def current_user
    now_user
  end

  # The plugin requires a way to log a user in. Call your auth frameworks equivalent below
  # if different. eg. for devise:
  #
  # def current_user=(user)
  #   sign_in(user)
  # end

  # Override this to deny the user or redirect to a login screen depending on your framework and app
  # if different. eg. for devise:
  #
  # def deny_access!
  #   raise Acl9::AccessDenied
  # end
end

