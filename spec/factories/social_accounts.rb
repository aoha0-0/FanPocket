# frozen_string_literal: true

FactoryBot.define do
  factory :social_account do
    association :user
    provider { 'line' }
    sequence(:uid) { |n| "line_uid_#{n}" }
  end
end
