# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      sign_in(resource) # Triggers JWT dispatch
      # Extract JWT token from Warden after sign_in
      token = request.env["warden-jwt_auth.token"]
      render :register_success, locals: { user: resource, token: token }
    else
      render json: {
        status: { code: 422, message: "User could not be created.", errors: resource.errors.full_messages }
      }, status: :unprocessable_entity
    end
  end
end
