# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UrlParsers', type: :request do
  describe 'GET /url_parsers/fetch_title' do
    it '特殊文字を含むタイトルをJSONで返す' do
      user = create(:user)
      sign_in user

      title = '<ライブのお知らせ>'

      allow_any_instance_of(UrlParsersController)
        .to receive(:extract_title).and_return(title)

      get '/url_parsers/fetch_title', params: { url: 'https://example.com' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        'title' => title
      )
    end

    it 'U+2028とU+2029を含むタイトルをJSONで返す' do
      user = create(:user)
      sign_in user

      title = "ライブ\u2028のお知らせ\u2029です"

      allow_any_instance_of(UrlParsersController)
        .to receive(:extract_title).and_return(title)

      get '/url_parsers/fetch_title',
          params: { url: 'https://example.com' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq('title' => title)
    end
  end
end
