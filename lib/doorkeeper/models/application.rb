module Doorkeeper
  class Application
    include Doorkeeper::OAuth::Helpers

    has_many :access_grants, :class_name => "Doorkeeper::AccessGrant"

    validates :name, :secret, :redirect_uri, :presence => true
    validates :uid, :presence => true, :uniqueness => true
    validate :validate_redirect_uri

    before_validation :generate_uid, :generate_secret, :on => :create

    def validate_redirect_uri
      return unless redirect_uri
      uri = URI.parse(redirect_uri)
      errors.add(:redirect_uri, "cannot contain a fragment.") unless uri.fragment.nil?
      errors.add(:redirect_uri, "must be an absolute URL.") if uri.scheme.nil? || uri.host.nil?
      errors.add(:redirect_uri, "cannot contain a query parameter.") unless uri.query.nil?
    rescue URI::InvalidURIError => e
      errors.add(:redirect_uri, "must be a valid URI.")
    end

    private

    def generate_uid
      self.uid = UniqueToken.generate_for :uid, self.class
    end

    def generate_secret
      self.secret = UniqueToken.generate_for :secret, self.class
    end
  end
end
