class Subdomain
  def self.matches?(request)
    s = subdomain(request)
    if s.present?
      s = real_subdomain(s)
      !s.blank? && s != 'www'
    end
  end

  def self.subdomain(request)
    if defined? request.subdomain
      request.subdomain
    else
      ActionDispatch::Http::URL.extract_subdomain(request, 1)
    end
  end

  def self.real_subdomain(subdomain)
    match = Rails.configuration.subdomain_regexp.match(subdomain)
    match && match[2]
  end
end
