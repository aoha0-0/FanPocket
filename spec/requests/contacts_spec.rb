# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contacts', type: :request do
  let(:user) { create(:user) }

  let(:valid_params) do
    {
      contact: {
        category: 'bug',
        content: 'お問い合わせフォームの送信確認です'
      }
    }
  end

  let(:invalid_params) do
    {
      contact: {
        category: '',
        content: ''
      }
    }
  end

  let(:delivery) do
    instance_double(
      ActionMailer::MessageDelivery,
      deliver_now: true
    )
  end

  before do
    sign_in user

    allow(ContactMailer)
      .to receive(:notification)
      .and_return(delivery)
  end

  describe 'GET /contact/new' do
    it 'お問い合わせ画面を表示する' do
      get new_contact_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('お問い合わせ')
    end
  end

  describe 'POST /contact' do
    context '有効なパラメータの場合' do
      it 'お問い合わせメールを送信する' do
        post contact_path, params: valid_params

        expect(ContactMailer)
          .to have_received(:notification)
          .with(
            an_instance_of(Contact),
            user
          )
      end

      it '設定画面へリダイレクトする' do
        post contact_path, params: valid_params

        expect(response).to redirect_to(settings_path)
      end

      it '送信完了メッセージを設定する' do
        post contact_path, params: valid_params

        expect(flash[:notice]).to eq('お問い合わせを送信しました')
      end
    end

    context '無効なパラメータの場合' do
      it 'お問い合わせメールを送信しない' do
        post contact_path, params: invalid_params

        expect(ContactMailer)
          .not_to have_received(:notification)
      end

      it '422を返す' do
        post contact_path, params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'バリデーションエラーを表示する' do
        post contact_path, params: invalid_params

        expect(response.body)
          .to include('問い合わせ種別を入力してください')

        expect(response.body)
          .to include('問い合わせ内容を入力してください')
      end
    end

    context '1分以内に再送信した場合' do
      it '2件目のメールを送信せず429を返す' do
        post contact_path, params: valid_params
        post contact_path, params: valid_params

        expect(ContactMailer)
          .to have_received(:notification)
          .once

        expect(response).to have_http_status(:too_many_requests)
        expect(response.body)
          .to include('続けて送信する場合は、少し時間を空けてください')
      end
    end
  end

  describe '認証' do
    context 'ログインしていない場合' do
      it 'ログイン画面へリダイレクトする' do
        sign_out user

        get new_contact_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
