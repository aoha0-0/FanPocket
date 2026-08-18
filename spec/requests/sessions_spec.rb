# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let(:user) do
    create(
      :user,
      email: 'test@example.com',
      password: 'password'
    )
  end

  describe 'POST /users/sign_in' do
    context '正しいメールアドレスとパスワードの場合' do
      let(:valid_params) do
        {
          user: {
            email: user.email,
            password: 'password'
          }
        }
      end

      it 'ログイン後にリダイレクトする' do
        post user_session_path, params: valid_params

        expect(response).to have_http_status(:redirect)
      end

      it 'ログインできる' do
        post user_session_path, params: valid_params

        get watchlists_path

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
