# frozen_string_literal: true
require "open-uri"

module Api
  class DateSuggestionsController < ApplicationController
    def index
      url = params[:url]
      return render json: { error: 'URLを入力してください' }, status: :bad_request if url.blank?

      target_text = fetch_target_text(url)
      suggestions = DateExtractorService.new(target_text).call

      render json: { suggestions: suggestions }
    rescue StandardError => e
      logger.error "DateSuggestions Error: #{e.message}"
      render json: { suggestions: [], error: 'ページの解析に失敗しました' }, status: :unprocessable_entity
    end

    private

    def fetch_target_text(url)
      html = URI.open(url).read
      doc = Nokogiri::HTML(html)

      doc.css("script, style").remove

      title = doc.title
      body = doc.at("body")&.text.to_s.squish

      "#{title} #{body}"
    end
  end
end
