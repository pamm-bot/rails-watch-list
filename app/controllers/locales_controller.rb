class LocalesController < ApplicationController
  allow_unauthenticated_access

  def update
    locale = params[:locale].to_sym
    session[:locale] = locale if I18n.available_locales.include?(locale)
    redirect_back fallback_location: root_path
  end
end
