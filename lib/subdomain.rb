class Subdomain
  def self.matches?(request)
    if request.subdomain.present?
      subdomain = real_subdomain(request.subdomain)
      !subdomain.blank? && subdomain != 'www'
    end

  end

  def self.real_subdomain(subdomain)
    match = Rails.configuration.subdomain_regexp.match(subdomain)
    match && match[2]
  end
end