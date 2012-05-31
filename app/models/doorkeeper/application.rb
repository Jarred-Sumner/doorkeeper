module Doorkeeper
  class Application < ActiveRecord::Base
    include Doorkeeper::OAuth::Helpers

    self.table_name  = :oauth_applications
    self.primary_key = 'uid'

    def id
      self.uid
    end

    belongs_to :owner, :class_name => "User"

    has_many :access_grants, :dependent => :destroy
    has_many :access_tokens, :dependent => :destroy
    has_many :authorized_tokens, :class_name => "AccessToken", :conditions => { :revoked_at => nil }
    has_many :authorized_applications, :through => :authorized_tokens, :source => :application

    validates :name, :secret, :redirect_uri, :presence => true
    validates :uid, :presence => true, :uniqueness => true
    validate :validate_redirect_uri
    validates_presence_of :owner, :if => :should_confirm?

    before_validation :generate_uid, :generate_secret, :generate_api_key!, :on => :create

    attr_accessible :name, :redirect_uri, :uid, :secret, :redirect_uri
    attr_readonly :privileged, :api_key

    def self.column_names_with_table
      self.column_names.map { |c| "oauth_applications.#{c}" }
    end

    def self.authorized_for(resource_owner)
      joins(:authorized_applications).
        where(:oauth_access_tokens => { :resource_owner_id => resource_owner.id } )
    end

    def validate_redirect_uri
      return unless redirect_uri
      uri = URI.parse(redirect_uri)
      errors.add(:redirect_uri, "cannot contain a fragment.") unless uri.fragment.nil?
      errors.add(:redirect_uri, "must be an absolute URL.") if uri.scheme.nil? || uri.host.nil?
      errors.add(:redirect_uri, "cannot contain a query parameter.") unless uri.query.nil?
    rescue URI::InvalidURIError => e
      errors.add(:redirect_uri, "must be a valid URI.")
    end

    def api_key
      @access_token ||= Doorkeeper::AccessToken.find_by_api_key_and_application_id(true, self.id) || generate_api_key!
    end


    private

    def generate_uid
      self.uid = UniqueToken.generate_for :uid, self.class
    end

    def generate_secret
      self.secret = UniqueToken.generate_for :secret, self.class
    end

    def should_confirm?
      Doorkeeper.configuration.should_confirm_application_owner
    end

    def generate_api_key!
      @access_token = Doorkeeper::AccessToken.new
      @access_token.resource_owner_id = self.owner_id
      @access_token.application_id    = self.id
      @access_token.expires_in        = nil
      @access_token.api_key           = true
      @access_token.save
      @access_token
    end

  end
end
