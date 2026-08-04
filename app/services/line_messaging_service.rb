# frozen_string_literal: true

require 'net/http'
require 'json'

class LineMessagingService
  ENDPOINT = 'https://api.line.me/v2/bot/message/push'

  class << self
    def push_text(line_user_id, text)
      response = send_request(line_user_id, text)

      return true if response.is_a?(Net::HTTPSuccess)

      log_error(response)
      false
    end

    def push_flex(line_user_id, title, message, url)
      response = send_flex_request(
        line_user_id,
        title,
        message,
        url
      )

      return true if response.is_a?(Net::HTTPSuccess)

      log_error(response)
      false
    end

    private

    def send_request(line_user_id, text)
      uri = URI(ENDPOINT)
      request = build_request(uri, line_user_id, text)

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
    end

    def send_flex_request(line_user_id, title, message, url)
      uri = URI(ENDPOINT)
      request = build_flex_request(uri, line_user_id, title, message, url)

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
    end

    def build_request(uri, line_user_id, text)
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = authorization_header
      request.body = message_body(line_user_id, text).to_json
      request
    end

    def build_flex_request(uri, line_user_id, title, message, url)
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = authorization_header
      request.body = LineFlexMessageBuilder.call(
        line_user_id,
        title,
        message,
        url
      ).to_json
      request
    end

    def authorization_header
      token = ENV.fetch('LINE_MESSAGING_CHANNEL_ACCESS_TOKEN')
      "Bearer #{token}"
    end

    def message_body(line_user_id, text)
      {
        to: line_user_id,
        messages: [{ type: 'text', text: text }]
      }
    end

    def log_error(response)
      Rails.logger.error(
        "LINE message failed: status=#{response.code} body=#{response.body}"
      )
    end
  end
end
