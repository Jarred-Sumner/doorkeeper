class Doorkeeper::AuthorizationsController < Doorkeeper::ApplicationController
  before_filter :authenticate_resource_owner!

  def new
    if authorization.valid?
      if authorization.access_token_exists?
        authorization.authorize
        redirect_to authorization.success_redirect_uri
      end
    elsif authorization.redirect_on_error?
      redirect_to authorization.invalid_redirect_uri
    else
      render :error
    end
  end

  def trusted
    if @application = Application.find_by_secret(params[:client_secret]) && (@application.privileged? || @application.owner_id == current_resource_owner.id) 
      @access_token                   = AccessToken.new
      @access_token.resource_owner_id = current_resource_owner.id
      @access_token.application_id    = @application.id
      @access_token.expires_in        = 15.years.from_now.seconds
      @access_token.save
      render :json => @access_token.as_json, :status => 200
    else
      render :nothing => true, :status => 403
    end
  end

  def create
    if authorization.authorize
      redirect_to authorization.success_redirect_uri
    elsif authorization.redirect_on_error?
      redirect_to authorization.invalid_redirect_uri
    else
      render :error
    end
  end

  def destroy
    authorization.deny
    redirect_to authorization.invalid_redirect_uri
  end

  private

  def authorization
    authorization_params = params.has_key?(:authorization) ? params[:authorization] : params
    @authorization ||= Doorkeeper::OAuth::AuthorizationRequest.new(current_resource_owner, authorization_params)
  end

end
