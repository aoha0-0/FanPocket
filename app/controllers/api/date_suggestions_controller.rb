# frozen_string_literal: true

module Api
  class DateSuggestionsController < ApplicationController
    def index
      url = params[:url]
      return render json: { error: 'URLを入力してください' }, status: :bad_request if url.blank?

      target_text = fetch_target_text(url)
      suggestions = DateExtractorService.new(target_text).call

      render json: { suggestions: suggestions }
    rescue StandardError => e
      logger.error "MetaInspector Error: #{e.message}"
      render json: { suggestions: [], error: 'ページの解析に失敗しました' }, status: :unprocessable_entity
    end

    private

    def fetch_target_text(url)
      page = MetaInspector.new(url, connection_options: { request: { timeout: 5 } })
      "#{page.title} #{page.description} #{page.text}"
    end
  end
end
