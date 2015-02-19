class Root
  def self.matches?(request)
    !Subdomain.matches?(request)
  end
end