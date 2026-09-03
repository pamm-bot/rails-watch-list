module ApplicationHelper
  LOCALE_FLAGS = { en: "🇬🇧", it: "🇮🇹", fr: "🇫🇷" }.freeze

  def available_locales
    I18n.available_locales
  end

  def locale_flag(locale)
    LOCALE_FLAGS[locale.to_sym]
  end

  # TMDb genre names are stored and matched in English; this renders the
  # label in the current UI language, falling back to the English name.
  def genre_label(english_name)
    return if english_name.blank?

    key = english_name.parameterize(separator: "_")
    t("genres.#{key}", default: english_name)
  end
end
