class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # added unless condition to avoid this error: verify_authenticity_token has not been defined
  protect_from_forgery unless: -> { request.format.json? }
end
