module Doorkeeper
  class AccessGrant < ActiveRecord::Base
    include Doorkeeper::OAuth::Helpers
    include Doorkeeper::Models::Expirable
    include Doorkeeper::Models::Revocable
    include Doorkeeper::Models::Scopes

    self.table_name = :oauth_access_grants

    belongs_to :application

    validates :resource_owner_id, :application_id, :token, :expires_in, :redirect_uri, :presence => true
    
    attr_accessible :resource_owner_id, :application_id, :token, :expires_in, :redirect_uri, :created_at, :revoked_at, :scopes
    before_validation :generate_token, :on => :create

    def accessible?
      !expired? && !revoked?
    end

    private

    def generate_token
      self.token = UniqueToken.generate_for :token, self.class
    end
  end
end
