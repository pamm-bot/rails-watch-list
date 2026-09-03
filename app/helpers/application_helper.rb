module ApplicationHelper
  # Inline SVG flags rather than emoji: regional-indicator flag emoji don't
  # render on Windows (they show up as "GB", "IT", ...). Each fills a circle
  # via preserveAspectRatio="slice".
  LOCALE_FLAGS = {
    en: <<~SVG.freeze,
      <svg viewBox="0 0 60 30" preserveAspectRatio="xMidYMid slice" aria-hidden="true">
        <clipPath id="flag-gb-c"><path d="M0,0 v30 h60 v-30 z"/></clipPath>
        <clipPath id="flag-gb-d"><path d="M30,15 h30 v15 z v15 h-30 z h-30 v-15 z v-15 h30 z"/></clipPath>
        <g clip-path="url(#flag-gb-c)">
          <path d="M0,0 v30 h60 v-30 z" fill="#012169"/>
          <path d="M0,0 L60,30 M60,0 L0,30" stroke="#fff" stroke-width="6"/>
          <path d="M0,0 L60,30 M60,0 L0,30" clip-path="url(#flag-gb-d)" stroke="#C8102E" stroke-width="4"/>
          <path d="M30,0 v30 M0,15 h60" stroke="#fff" stroke-width="10"/>
          <path d="M30,0 v30 M0,15 h60" stroke="#C8102E" stroke-width="6"/>
        </g>
      </svg>
    SVG
    it: <<~SVG.freeze,
      <svg viewBox="0 0 3 2" preserveAspectRatio="xMidYMid slice" aria-hidden="true">
        <rect width="1" height="2" x="0" fill="#009246"/>
        <rect width="1" height="2" x="1" fill="#fff"/>
        <rect width="1" height="2" x="2" fill="#CE2B37"/>
      </svg>
    SVG
    fr: <<~SVG.freeze
      <svg viewBox="0 0 3 2" preserveAspectRatio="xMidYMid slice" aria-hidden="true">
        <rect width="1" height="2" x="0" fill="#0055A4"/>
        <rect width="1" height="2" x="1" fill="#fff"/>
        <rect width="1" height="2" x="2" fill="#EF4135"/>
      </svg>
    SVG
  }.freeze

  def available_locales
    I18n.available_locales
  end

  def locale_flag(locale)
    raw LOCALE_FLAGS[locale.to_sym]
  end

  # TMDb genre names are stored and matched in English; this renders the
  # label in the current UI language, falling back to the English name.
  def genre_label(english_name)
    return if english_name.blank?

    key = english_name.parameterize(separator: "_")
    t("genres.#{key}", default: english_name)
  end
end
