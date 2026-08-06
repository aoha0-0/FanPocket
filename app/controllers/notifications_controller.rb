# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.recent
  end

  def show
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!

    redirect_to watchlist_path(@notification.watchlist)
  end
end
