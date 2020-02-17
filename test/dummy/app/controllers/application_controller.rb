# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_user

  private

    def current_user
      if session[:current_user_id].present?
        @_current_user ||=
          User.find_by(id: session[:current_user_id])
      end
    end

    def require_signed_in
      redirect_to users_url unless current_user
    end
    alias authenticate_user! require_signed_in
end
