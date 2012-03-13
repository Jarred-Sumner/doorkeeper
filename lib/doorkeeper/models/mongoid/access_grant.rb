module Doorkeeper
  class AccessGrant
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in = :oauth_access_grants

    field :resource_owner_id, :type => Hash
    field :application_id, :type => Hash
    field :token, :type => String
    field :expires_in, :type => Integer
    field :redirect_uri, :type => String
    field :revoked_at, :type => DateTime
    field :scopes, :type => String
    p "bosta"

    def self.find_by_token(token)
      where(:token => token).first
    end
  end
end
