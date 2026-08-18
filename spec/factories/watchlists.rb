# frozen_string_literal: true

FactoryBot.define do
  factory :watchlist do
    association :user
    title { 'チケット申し込み' }
    start_at { 1.day.from_now }
    end_at { 3.days.from_now }
  end
end
