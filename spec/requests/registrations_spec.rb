# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  describe 'POST /users' do
    context '有効なパラメータの場合' do
      let(:valid_params) do
        {
          user: {
            email: 'test@example.com',
            password: 'password',
            password_confirmation: 'password'
          }
        }
      end

      it 'ユーザーを1件作成する' do
        expect do
          post user_registration_path, params: valid_params
        end.to change(User, :count).by(1)
      end

      it '登録後にリダイレクトする' do
        post user_registration_path, params: valid_params

        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
