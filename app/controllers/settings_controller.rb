# frozen_string_literal: true

class SettingsController < ApplicationController
  before_action :authenticate_user!

  def show
    @notification_setting = current_user.notification_setting
  end

  def update
    @notification_setting = current_user.notification_setting

    if @notification_setting.update(notification_setting_params)
      redirect_to settings_path, notice: '通知設定を更新しました'
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def notification_setting_params
    params.require(:notification_setting).permit(
      :email_three_days_before,
      :email_day_before,
      :email_deadline_same_day,
      :email_start_same_day,
      :line_start_ten_minutes_before,
      :line_deadline_three_hours_before
    )
  end
end
