class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_locale

  private

  def set_locale
    session_locale = session[:locale]&.to_sym
    I18n.locale = I18n.available_locales.include?(session_locale) ? session_locale : I18n.default_locale
  end
end
