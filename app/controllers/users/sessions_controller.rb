# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if current_user.present?
      token = request.env["warden-jwt_auth.token"]
      render :login_success, locals: { user: current_user, token: token }
    else
      render json: {
        status: { code: 401, message: "Invalid login credentials." }
      }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    head :no_content
  end
end
