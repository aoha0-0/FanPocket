# frozen_string_literal: true

require 'net/http'
require 'uri'

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
      uri = URI.parse(url)

      response = Net::HTTP.get_response(uri)
      raise 'ページの取得に失敗しました' unless response.is_a?(Net::HTTPSuccess)

      doc = Nokogiri::HTML(response.body)
      doc.css('script, style').remove

      title = doc.title
      body = doc.at('body')&.text.to_s.squish

      "#{title} #{body}"
    end
  end
end
