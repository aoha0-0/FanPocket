# frozen_string_literal: true

class LineFlexMessageBuilder
  class << self
    def call(line_user_id, title, message, url)
      flex_message_body(line_user_id, title, message, url)
    end

    private

    def flex_message_body(line_user_id, title, message, url)
      {
        to: line_user_id,
        messages: [
          {
            type: 'flex',
            altText: "#{title}のお知らせ",
            contents: flex_contents(title, message, url)
          }
        ]
      }
    end

    def flex_contents(title, message, url)
      {
        type: 'bubble',
        body: body_contents(title, message),
        footer: footer_contents(url)
      }
    end

    def body_contents(title, message)
      {
        type: 'box',
        layout: 'vertical',
        spacing: 'md',
        contents: [
          title_contents(title),
          message_contents(message)
        ]
      }
    end

    def title_contents(title)
      {
        type: 'text',
        text: title,
        weight: 'bold',
        size: 'lg',
        wrap: true
      }
    end

    def message_contents(message)
      {
        type: 'text',
        text: message,
        size: 'md',
        wrap: true
      }
    end

    def footer_contents(url)
      {
        type: 'box',
        layout: 'vertical',
        contents: [button_contents(url)]
      }
    end

    def button_contents(url)
      {
        type: 'button',
        style: 'primary',
        action: {
          type: 'uri',
          label: 'FanPocketで確認する',
          uri: url
        }
      }
    end
  end
end
