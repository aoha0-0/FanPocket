# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :watchlists, dependent: :destroy

  after_create_commit :send_welcome_email

  private

  def send_welcome_email
    WelcomeMailer.send_welcome_email(self).deliver_later
  end
end
