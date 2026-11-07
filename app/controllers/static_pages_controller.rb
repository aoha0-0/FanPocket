# frozen_string_literal: true

class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[terms privacy guide]
  before_action :set_back_path, only: %i[terms privacy guide]

  def terms; end

  def privacy; end

  def guide; end

  private

  def set_back_path
    fallback_path = user_signed_in? ? watchlists_path : new_user_session_path

    @back_path = fallback_path
    return if request.referer.blank?
    return unless same_origin_referer?

    @back_path = request.referer
  end

  def same_origin_referer?
    referer_uri = URI.parse(request.referer)

    referer_uri.host == request.host &&
      referer_uri.port == request.port &&
      referer_uri.scheme == request.scheme
  rescue URI::InvalidURIError
    false
  end
end
