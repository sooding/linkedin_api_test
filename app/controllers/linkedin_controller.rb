require 'linked_in/general_api'

class LinkedinController < ApplicationController

  rescue_from LinkedIn::Errors::GeneralError, NoMethodError, LinkedIn::Errors::NotFoundError do |exception|
      flash[:error] = exception.message
      redirect_to linkedin_path
  end

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
      @search_results = linkedin_client.api("companies/universal-name=#{params[:q]}:(id,name,logo-url,description)")
    when 'location'
      @search_results = linkedin_client.api("companies/universal-name=#{params[:q]}")
    when 'api'
      # TODO: Do this better, cleaner
      @query = params[:q].blank? ? 'people/~' : params[:q]
      @post_process = params[:post_process].blank? ? nil : params[:post_process]

      @search_results = linkedin_client.api(@query)
      if @post_process
        eval "@search_results = @search_results.#{params[:post_process]}"
      end
    end

    if @search_results.is_a?(Array)
      @search_headings = @search_results.first.keys
    elsif @search_results
      @search_headings = @search_results.keys
    end

    @people_search_options = { 'First Name' => 'first_name', 'Last Name' => 'last_name' }
    @company_search_options = { 'Name' => 'name', 'Location' => 'location' }

    if current_user.has_service?(:linkedin)
      set_profile_info
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
    set_profile_info
    redirect_to linkedin_path
  end

private

  def profile
    session[:profile] ||= linkedin_client.api('people/~:(id,first-name,last-name,headline,picture-url)')
  end

  def set_profile_info
    @profile_id = profile.try(:id)
    @profile_first_name = profile.try(:first_name)
    @profile_last_name = profile.try(:last_name)
    @profile_headline = profile.try(:headline)
    @profile_avatar = profile.try(:picture_url)
  end

  def linkedin_connect
    linkedin_client.authorize_from_access(current_user.get_service_key1(:linkedin), current_user.get_service_key2(:linkedin))
  end

end

