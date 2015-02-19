class HelpController < ApplicationController
  skip_authorization_check

  def show
    file_name = params[:category].blank? ? "README" : params[:category]
    @doc_file = Rails.root.join('doc', "#{file_name}.#{I18n.locale}.md")

    if File.exists?(@doc_file)
      render 'show'
    else
      not_found!
    end
  end
end
