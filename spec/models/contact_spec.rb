# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe 'バリデーション' do
    context '問い合わせ種別と内容が入力されている場合' do
      it '有効である' do
        contact = Contact.new(
          category: 'bug',
          content: '登録画面でエラーが発生しました'
        )

        expect(contact).to be_valid
      end
    end

    context '問い合わせ種別がない場合' do
      it '無効である' do
        contact = Contact.new(
          category: '',
          content: '登録画面でエラーが発生しました'
        )

        expect(contact).not_to be_valid
      end
    end

    context '問い合わせ種別が不正な場合' do
      it '無効である' do
        contact = Contact.new(
          category: 'invalid',
          content: '登録画面でエラーが発生しました'
        )

        expect(contact).not_to be_valid
      end
    end

    context '問い合わせ内容がない場合' do
      it '無効である' do
        contact = Contact.new(
          category: 'bug',
          content: ''
        )

        expect(contact).not_to be_valid
      end
    end

    context '問い合わせ内容が2000文字の場合' do
      it '有効である' do
        contact = Contact.new(
          category: 'request',
          content: 'あ' * 2000
        )

        expect(contact).to be_valid
      end
    end

    context '問い合わせ内容が2000文字を超える場合' do
      it '無効である' do
        contact = Contact.new(
          category: 'request',
          content: 'あ' * 2001
        )

        expect(contact).not_to be_valid
      end
    end

    context 'メールアドレスが必須の場合' do
      it 'メールアドレスが未入力だと無効である' do
        contact = Contact.new(
          category: 'bug',
          content: '登録画面でエラーが発生しました',
          email_required: true,
          email: ''
        )

        expect(contact).not_to be_valid
        expect(contact.errors[:email]).to include('を入力してください')
      end
    end

    context 'メールアドレスが必須ではない場合' do
      it 'メールアドレスが未入力でも有効である' do
        contact = Contact.new(
          category: 'bug',
          content: '登録画面でエラーが発生しました',
          email_required: false,
          email: ''
        )

        expect(contact).to be_valid
      end
    end

    context 'メールアドレスの形式が不正な場合' do
      it '無効である' do
        contact = Contact.new(
          category: 'bug',
          content: '登録画面でエラーが発生しました',
          email_required: true,
          email: 'invalid-email'
        )

        expect(contact).not_to be_valid
        expect(contact.errors[:email]).to include('は不正な値です')
      end
    end
  end
end
