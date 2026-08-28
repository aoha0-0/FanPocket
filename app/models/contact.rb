# frozen_string_literal: true

class Contact
  include ActiveModel::Model

  CATEGORIES = {
    'bug' => '不具合報告',
    'request' => 'ご意見・ご要望',
    'other' => 'その他'
  }.freeze

  attr_accessor :category, :content

  validates :category,
            presence: true,
            inclusion: { in: CATEGORIES.keys, allow_blank: true }

  validates :content,
            presence: true,
            length: { maximum: 2000 }
end
