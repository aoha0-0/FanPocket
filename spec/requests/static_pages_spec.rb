# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do
  describe 'GET /guide' do
    it '未ログインでも使い方ガイドを表示できる' do
      get guide_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('使い方ガイド')
    end
  end

  describe 'GET /terms' do
    it '未ログインでも利用規約を表示できる' do
      get terms_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('利用規約')
    end
  end

  describe 'GET /privacy' do
    it '未ログインでもプライバシーポリシーを表示できる' do
      get privacy_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('プライバシーポリシー')
    end
  end

  describe '戻るリンク' do
    context '未ログインで移動元のURLがない場合' do
      it 'ログイン画面へのリンクを表示する' do
        get guide_path

        expect(response.body)
          .to include("href=\"#{new_user_session_path}\"")
      end
    end

    context 'ログイン中で移動元のURLがない場合' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it '予定一覧へのリンクを表示する' do
        get guide_path

        expect(response.body)
          .to include("href=\"#{watchlists_path}\"")
      end
    end

    context '同じサイト内のページから移動した場合' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it '移動元のページへのリンクを表示する' do
        get guide_path, headers: {
          'HTTP_REFERER' => "http://www.example.com#{settings_path}"
        }

        expect(response.body)
          .to include("href=\"#{settings_path}\"")
      end
    end

    context '外部サイトから移動した場合' do
      it 'ログイン画面へのリンクを表示する' do
        get guide_path, headers: {
          'HTTP_REFERER' => 'https://example.org/other-page'
        }

        expect(response.body)
          .to include("href=\"#{new_user_session_path}\"")
      end
    end

    context '移動元のURLが不正な場合' do
      it 'ログイン画面へのリンクを表示する' do
        get guide_path, headers: {
          'HTTP_REFERER' => 'http://[invalid'
        }

        expect(response).to have_http_status(:ok)
        expect(response.body)
          .to include("href=\"#{new_user_session_path}\"")
      end
    end
  end

  describe '共通ヘッダー' do
    context '未ログインの場合' do
      it '通知リンクを表示しない' do
        get guide_path

        expect(response.body)
          .not_to include('aria-label="通知を確認する"')
      end

      it 'メニューボタンを非表示にする' do
        get guide_path

        expect(response.body)
          .to include('class="hidden items-center justify-center')
      end
    end

    context 'ログイン中の場合' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it '通知リンクを表示する' do
        get guide_path

        expect(response.body)
          .to include('aria-label="通知を確認する"')
      end

      it 'PC用のメニューボタンを表示する設定になっている' do
        get guide_path

        expect(response.body)
          .to include('class="hidden md:flex items-center justify-center')
      end
    end

    context '未ログインで使い方ガイドを表示した場合' do
      it 'ログイン画面に戻るヘッダーリンクを表示する' do
        get guide_path

        expect(response.body).to include(
          "href=\"#{new_user_session_path}\"",
          'aria-label="前の画面に戻る"'
        )
      end
    end
  end

  describe '下部ナビゲーション' do
    context 'ログイン中の場合' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it '使い方ガイドに下部ナビゲーションを表示する' do
        get guide_path

        expect(response.body)
          .to include('aria-label="メインナビゲーション"')
      end

      it '利用規約に下部ナビゲーションを表示しない' do
        get terms_path

        expect(response.body)
          .not_to include('aria-label="メインナビゲーション"')
      end

      it 'プライバシーポリシーに下部ナビゲーションを表示しない' do
        get privacy_path

        expect(response.body)
          .not_to include('aria-label="メインナビゲーション"')
      end
    end

    context '未ログインの場合' do
      it '使い方ガイドに下部ナビゲーションを表示しない' do
        get guide_path

        expect(response.body)
          .not_to include('aria-label="メインナビゲーション"')
      end

      it '利用規約に下部ナビゲーションを表示しない' do
        get terms_path

        expect(response.body)
          .not_to include('aria-label="メインナビゲーション"')
      end

      it 'プライバシーポリシーに下部ナビゲーションを表示しない' do
        get privacy_path

        expect(response.body)
          .not_to include('aria-label="メインナビゲーション"')
      end
    end
  end
end
