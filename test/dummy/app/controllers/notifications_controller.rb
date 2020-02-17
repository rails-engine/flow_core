# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user
                     .notifications
                     .includes(task: { executable: %i[workflow transition] })
                     .order(created_at: :desc)
  end
end
