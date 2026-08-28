# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactMailer, type: :mailer do
  let(:user) do
    create(
      :user,
      email: 'user@example.com'
    )
  end

  let(:contact) do
    Contact.new(
      category: 'bug',
      content: "お問い合わせフォームの送信確認です。\n2行目の内容です。"
    )
  end

  let(:mail) do
    described_class.notification(contact, user)
  end

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV)
      .to receive(:fetch)
      .with('CONTACT_EMAIL')
      .and_return('owner@example.com')
  end

  describe '#notification' do
    it '運営者のメールアドレスへ送信する' do
      expect(mail.to).to eq(['owner@example.com'])
    end

    it 'ユーザーのメールアドレスを返信先に設定する' do
      expect(mail.reply_to).to eq(['user@example.com'])
    end

    it '問い合わせ種別を件名に含める' do
      expect(mail.subject).to eq(
        '【FanPocket】不具合報告のお問い合わせ'
      )
    end

    it 'HTML本文に問い合わせ情報を含める' do
      body = mail.html_part.body.decoded

      expect(body).to include('不具合報告')
      expect(body).to include('お問い合わせフォームの送信確認です。')
      expect(body).to include(user.id.to_s)
      expect(body).to include('user@example.com')
    end

    it 'テキスト本文に問い合わせ情報を含める' do
      body = mail.text_part.body.decoded

      expect(body).to include('不具合報告')
      expect(body).to include('お問い合わせフォームの送信確認です。')
      expect(body).to include(user.id.to_s)
      expect(body).to include('user@example.com')
    end
  end
end
