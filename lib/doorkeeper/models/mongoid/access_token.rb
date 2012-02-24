module Doorkeeper
  class AccessToken
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in = :oauth_access_tokens

    field :resource_owner_id, :type => Hash
    field :application_id, :type => Hash
    field :token, :type => String
    field :refresh_token, :type => String
    field :expires_in, :type => Integer
    field :revoked_at, :type => DateTime
    field :scopes, :type => String
  end
end
