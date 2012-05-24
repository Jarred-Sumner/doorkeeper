class Doorkeeper::AuthorizationsController < Doorkeeper::ApplicationController
  before_filter :authenticate_resource_owner!
  include ActionView::Helpers::DateHelper

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
    if @application = Doorkeeper::Application.find(params[:client_id])
      if (@user = User.authenticate(params[:username], params[:password])).present? && (@application.privileged? || @user.id == @application.owner_id)
        @access_token                   = Doorkeeper::AccessToken.new
        @access_token.resource_owner_id = @user.id
        @access_token.application_id    = @application.id
        @access_token.expires_in        = nil
        @access_token.save
        # Yeah, this is extremeley messy.
        render :inline => access_token, :status => 200
      else
        render :nothing => true, :status => 401
      end
    else
      render :nothing => true, :status => 400
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

  def access_token
    { :access_token => @access_token.token, :expires_in => @access_token.expires_in, :token_type => "bearer" }.to_json
  end

end
