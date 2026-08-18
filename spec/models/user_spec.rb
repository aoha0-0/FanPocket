# frozen_string_literal: true

require 'rails_helper'
require 'ostruct'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    let(:user) { build(:user) }

    context '必要な情報が揃っている場合' do
      it '有効である' do
        expect(user).to be_valid
      end
    end

    context 'メールアドレスがない場合' do
      it '無効である' do
        user = build(:user, email: nil)

        expect(user).not_to be_valid
      end
    end

    context 'LINEログインの場合' do
      it 'メールアドレスがなくても有効である' do
        user = build(
          :user,
          email: nil,
          omniauth_provider: 'line'
        )

        expect(user).to be_valid
      end
    end
  end

  describe '#link_social_account' do
    let(:user) { create(:user) }

    let(:auth) do
      OpenStruct.new(
        provider: 'line',
        uid: 'line_uid_123'
      )
    end

    context '初めて連携する場合' do
      it ':successを返す' do
        result = user.link_social_account(auth)

        expect(result).to eq(:success)
      end

      it 'SocialAccountが1件作成される' do
        expect do
          user.link_social_account(auth)
        end.to change(SocialAccount, :count).by(1)
      end
    end

    context 'すでに連携済みの場合' do
      before do
        user.link_social_account(auth)
      end

      it ':already_linkedを返す' do
        result = user.link_social_account(auth)

        expect(result).to eq(:already_linked)
      end

      it 'SocialAccountが作成されない' do
        expect do
          user.link_social_account(auth)
        end.not_to change(SocialAccount, :count)
      end
    end

    context '他のユーザーがすでに連携している場合' do
      it ':takenを返す' do
        other_user = create(:user)

        create(
          :social_account,
          user: other_user,
          provider: 'line',
          uid: 'line_uid_123'
        )

        result = user.link_social_account(auth)

        expect(result).to eq(:taken)
      end
    end
  end

  describe '#linked_with?' do
    let(:user) { create(:user) }

    context '指定したSNSと連携している場合' do
      it 'trueを返す' do
        create(
          :social_account,
          user: user,
          provider: 'line'
        )

        result = user.linked_with?('line')

        expect(result).to be true
      end
    end

    context '指定したSNSと連携していない場合' do
      it 'falseを返す' do
        result = user.linked_with?('line')

        expect(result).to be false
      end
    end
  end

  describe '作成時の処理' do
    it 'NotificationSettingが1件作成される' do
      expect do
        create(:user)
      end.to change(NotificationSetting, :count).by(1)
    end

    context 'メールアドレスがある場合' do
      it 'WelcomeMailerが呼ばれる' do
        expect(WelcomeMailer)
          .to receive(:send_welcome_email)
          .and_call_original

        create(:user)
      end
    end

    describe '.from_omniauth' do
      let(:user) { create(:user) }

      let(:auth) do
        OpenStruct.new(
          provider: 'line',
          uid: 'line_uid_123',
          info: OpenStruct.new(
            email: nil
          )
        )
      end

      context 'SNSアカウントがすでに登録されている場合' do
        it '既存のUserを返す' do
          create(
            :social_account,
            user: user,
            provider: 'line',
            uid: 'line_uid_123'
          )

          result = User.from_omniauth(auth)

          expect(result[:user]).to eq(user)
        end

        it 'createdがfalseになる' do
          create(
            :social_account,
            user: user,
            provider: 'line',
            uid: 'line_uid_123'
          )

          result = User.from_omniauth(auth)

          expect(result[:created]).to be false
        end
      end

      context 'SNSアカウントがまだ登録されていない場合' do
        it '新しいUserが作成される' do
          expect do
            User.from_omniauth(auth)
          end.to change(User, :count).by(1)
        end

        it 'createdがtrueになる' do
          result = User.from_omniauth(auth)

          expect(result[:created]).to be true
        end
      end
    end
  end
end
