module Doorkeeper
  class ApplicationsController < Doorkeeper::ApplicationController
    respond_to :html

    before_filter :authenticate_admin!, :authenticate_resource_owner!

    def index
      @applications = Application.where(:owner_id => current_resource_owner.id)
    end

    def new
      @application = Application.new
    end

    def create
      @application = Application.new(params[:application])
      render :status => 500 if @application.owner_id != current_resource_owner.id
      flash[:notice] = "Application created" if @application.save
      respond_with @application
    end

    def show
      @application = Application.find_by_uid_and_owner_id(params[:id], current_resource_owner.id)
    end
    
    def edit
      @application = Application.find_by_uid_and_owner_id(params[:id], current_resource_owner.id)
    end

    def update
      @application = Application.find_by_uid_and_owner_id(params[:id], current_resource_owner.id)
      flash[:notice] = "Application updated" if @application.update_attributes(params[:application])
      respond_with @application
    end

    def destroy
      @application = Application.find_by_uid_and_owner_id(params[:id], current_resource_owner.id)
      flash[:notice] = "Application deleted" if @application.destroy
      redirect_to applications_url
    end
  end
end
