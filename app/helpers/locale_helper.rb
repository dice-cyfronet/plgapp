module LocaleHelper
  def locale_link(locale)
    content_tag(:a, locale.upcase,
                class: "btn btn-default#{locale_active(locale)}",
                href: "?locale=#{locale}")
  end

  private

  def locale_active(locale)
    I18n.locale == locale ? ' active' : ''
  end
end
