# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateExtractorService do
  include ActiveSupport::Testing::TimeHelpers

  describe '#call' do
    context '開始日時と締切日時を含む場合' do
      it '期間として開始日時と締切日時を取得する' do
        text = '受付期間：2026年5月8日 20:00〜2026年5月10日 23:59'

        result = described_class.new(text).call

        expect(result).to include(
          {
            label: '開始: 2026年5月8日 20:00',
            value: '2026-05-08T20:00'
          },
          {
            label: '締切: 2026年5月10日 23:59',
            value: '2026-05-10T23:59'
          }
        )
      end
    end

    context '年が省略されている場合' do
      it '現在年を補完して日時を取得する' do
        travel_to Time.zone.local(2026, 9, 12) do
          text = '受付開始：5月8日 20:00'

          result = described_class.new(text).call

          expect(result).to include(
            {
              label: '候補: 5月8日 20:00',
              value: '2026-05-08T20:00'
            }
          )
        end
      end
    end

    context '時間が省略されている場合' do
      it '00:00を補完して日時を取得する' do
        text = '受付開始：2026年5月8日'

        result = described_class.new(text).call

        expect(result).to include(
          {
            label: '候補: 2026年5月8日',
            value: '2026-05-08T00:00'
          }
        )
      end
    end

    context '曜日を含む場合' do
      it '曜日を除いて日時を取得する' do
        text = '受付開始：2026年5月8日（金）20:00'

        result = described_class.new(text).call

        expect(result).to include(
          {
            label: '候補: 2026年5月8日（金）20:00',
            value: '2026-05-08T20:00'
          }
        )
      end
    end

    context '日付を含まない場合' do
      it '候補を返さない' do
        text = 'チケット受付のお知らせです'

        result = described_class.new(text).call

        expect(result).to eq([])
      end
    end

    context '空文字の場合' do
      it '候補を返さない' do
        result = described_class.new('').call

        expect(result).to eq([])
      end
    end

    context 'nilの場合' do
      it '候補を返さない' do
        result = described_class.new(nil).call

        expect(result).to eq([])
      end
    end

    context '同じ日時が複数存在する場合' do
      it '重複を除去して1件だけ返す' do
        text = '受付開始：2026年5月8日 20:00、再案内：2026年5月8日 20:00'

        result = described_class.new(text).call

        expect(result.count { |item| item[:value] == '2026-05-08T20:00' }).to eq(1)
      end
    end
  end
end
