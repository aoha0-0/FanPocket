# frozen_string_literal: true

class Contact
  include ActiveModel::Model

  CATEGORIES = {
    'bug' => '不具合報告',
    'request' => 'ご意見・ご要望',
    'other' => 'その他'
  }.freeze

  attr_accessor :category, :content, :email, :email_required, :website

  validates :category,
            presence: true,
            inclusion: { in: CATEGORIES.keys, allow_blank: true }

  validates :content,
            presence: true,
            length: { maximum: 2000 }

  validates :email, presence: true, if: :email_required
  validates :email,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            allow_blank: true
end
