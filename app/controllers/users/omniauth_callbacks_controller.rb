module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_filter :verify_authenticity_token, only: [:open_id, :failure]

    def open_id
      @user = User.from_plgrid_omniauth(auth)

      if @user.persisted?
        session['proxy'] = proxy(auth.info)
        sign_in_and_redirect @user, event: :authentication
        if is_navigational_format?
          set_flash_message(:notice, :success, kind: 'open_id')
        end
      else
        session['devise.open_id_data'] = auth.except('extra')
        redirect_to root_url
      end
    end

    private

    def proxy(info)
      info.proxy + info.proxyPrivKey + info.userCert
    end

    def auth
      @auth ||= env['omniauth.auth']
    end
  end
end
