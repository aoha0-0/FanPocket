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

    def send_line_notification(user, content)
      line_account = user.social_accounts.find_by(provider: 'line')
      return unless line_account

      push_text(line_account.uid, content)
    end

    private

    def send_request(line_user_id, text)
      uri = URI(ENDPOINT)
      request = build_request(uri, line_user_id, text)

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
