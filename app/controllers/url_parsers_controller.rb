# frozen_string_literal: true

class UrlParsersController < ApplicationController
  def fetch_title
    url = params[:url]
    return render json: { error: 'URLが入力されていません' }, status: :bad_request if url.blank?

    title = extract_title(url)
    return render json: { title: title } if title.present?

    render json: { error: 'タイトルが取得できませんでした' }, status: :unprocessable_entity
  rescue MetaInspector::Error, StandardError => e
    logger.error "URL解析エラー: #{e.message}"
    render json: { error: 'タイトルが取得できませんでした' }, status: :unprocessable_entity
  end

  private

  def extract_title(url)
    page = MetaInspector.new(url, connection_timeout: 5, read_timeout: 5, retries: 1)
    page.best_title
  end
end
