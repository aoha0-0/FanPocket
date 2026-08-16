# frozen_string_literal: true

class OnboardingsController < ApplicationController
  def update
    current_user.update!(onboarding_completed_at: Time.current)

    redirect_to watchlists_path
  end
end
