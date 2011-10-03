require 'linked_in/general_api'

class LinkedinController < ApplicationController

  def new
    if current_user.has_service?(:linkedin)
      linkedin_connect
      redirect_to linkedin_path
      return
    end
    request_token = linkedin_client.request_token(:oauth_callback => callback_linkedin_url)
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret
    redirect_to linkedin_client.request_token.authorize_url
  end

  def show
    case params[:type]
    when 'first_name'
      @search_results = linkedin_client.search(:first_name => params[:q]).people.all
    when 'last_name'
      @search_results = linkedin_client.search(:last_name => params[:q]).people.all
    when 'name'
      @search_results = linkedin_client.api('company-search', :name => params[:q]).companies.all
    when 'location'
      @search_results = linkedin_client.api('company-search', 'locations:(address:(city))' => params[:q]).companies.all
    when 'api'
      @search_results = linkedin_client.api(params[:path], eval(params[:q]))
      @query = params[:q]
      @path = params[:path]
      if @post_process = params[:post_process]
        eval "@search_results = @search_results.#{params[:post_process]}"
      end
    end

    @search_headings = @search_results.first.keys if @search_results
    @people_search_options = { 'First Name' => 'first_name', 'Last Name' => 'last_name' }
    @company_search_options = { 'Name' => 'name', 'Location' => 'location' }

    if current_user.has_service?(:linkedin)
      get_api_info
    end
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
    get_api_info
    redirect_to linkedin_path
  end

private

  def get_api_info
    @profile = Rails.cache.fetch(:profile) { linkedin_client.profile }
    @connections = Rails.cache.fetch(:connections) { linkedin_client.connections }
  end

  def linkedin_connect
    linkedin_client.authorize_from_access(current_user.get_service_key1(:linkedin), current_user.get_service_key2(:linkedin))
  end

end

