module OauthHelper
  def stub_oauth(provider, options = {})
    OmniAuth.config.add_mock(
      provider,
      info: {
        nickname: options[:nickname],
        name: options[:name],
        email: options[:email],
        proxy: 'a',
        userCert: 'b',
        proxyPrivKey: 'c'
      },
      provider: provider,
      uid: '123'
    )
  end
end
