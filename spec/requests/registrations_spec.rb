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

  describe 'DELETE /users' do
    context 'ログインしている場合' do
      let!(:user) { create(:user) }
      let!(:watchlist) { create(:watchlist, user:) }
      let!(:tag) { Tag.create!(user:, name: '超特急') }
      let!(:watchlist_tag) { WatchlistTag.create!(watchlist:, tag:) }
      let!(:social_account) { create(:social_account, user:) }
      let!(:notification_setting) { user.notification_setting }
      let!(:notification) do
        Notification.create!(
          user:,
          watchlist:,
          notification_type: :deadline_three_days_before,
          title: '締切3日前のお知らせ',
          message: '締切が近づいています'
        )
      end

      let!(:notification_delivery) do
        NotificationDelivery.create!(
          watchlist:,
          channel: :email,
          notification_type: :deadline_three_days_before,
          sent_at: Time.current
        )
      end

      let!(:other_user) { create(:user) }
      let!(:other_watchlist) { create(:watchlist, user: other_user) }

      before do
        sign_in user
      end

      it 'ユーザーと関連データを削除し、他ユーザーのデータは残す' do
        delete user_registration_path

        expect(User.exists?(user.id)).to be false
        expect(Watchlist.exists?(watchlist.id)).to be false
        expect(Tag.exists?(tag.id)).to be false
        expect(WatchlistTag.exists?(watchlist_tag.id)).to be false
        expect(SocialAccount.exists?(social_account.id)).to be false
        expect(NotificationSetting.exists?(notification_setting.id)).to be false
        expect(Notification.exists?(notification.id)).to be false
        expect(NotificationDelivery.exists?(notification_delivery.id)).to be false

        expect(User.exists?(other_user.id)).to be true
        expect(Watchlist.exists?(other_watchlist.id)).to be true
      end

      it '削除後にログアウトしてログイン画面へリダイレクトする' do
        delete user_registration_path

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:notice]).to eq(
          I18n.t('devise.registrations.destroyed')
        )

        get settings_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログインしていない場合' do
      let!(:user) { create(:user) }

      it 'ユーザーを削除せずログイン画面へリダイレクトする' do
        expect do
          delete user_registration_path
        end.not_to change(User, :count)

        expect(response).to redirect_to(new_user_session_path)
        expect(User.exists?(user.id)).to be true
      end
    end
  end
end
