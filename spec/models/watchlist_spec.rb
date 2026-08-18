# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Watchlist, type: :model do
  describe 'バリデーション' do
    context '必要な情報が揃っている場合' do
      it '有効である' do
        watchlist = build(:watchlist)

        expect(watchlist).to be_valid
      end
    end

    context 'タイトルがない場合' do
      it '無効である' do
        watchlist = build(:watchlist, title: nil)

        expect(watchlist).not_to be_valid
      end
    end

    context 'タイトルが255文字の場合' do
      it '有効である' do
        watchlist = build(:watchlist, title: 'a' * 255)

        expect(watchlist).to be_valid
      end
    end

    context 'タイトルが256文字の場合' do
      it '無効である' do
        watchlist = build(:watchlist, title: 'a' * 256)

        expect(watchlist).not_to be_valid
      end
    end

    context '開始日時も締切日時もない場合' do
      it '無効である' do
        watchlist = build(
          :watchlist,
          start_at: nil,
          end_at: nil
        )

        expect(watchlist).not_to be_valid
      end
    end

    context '開始日時があり締切日時がない場合' do
      it '締切日時が開始日の終わりに補完される' do
        watchlist = build(
          :watchlist,
          start_at: 3.days.from_now,
          end_at: nil
        )

        watchlist.valid?

        expect(watchlist.end_at).to be_within(1.second).of(watchlist.start_at.end_of_day)
      end
    end

    context '締切日時が開始日時より前の場合' do
      it '無効である' do
        watchlist = build(
          :watchlist,
          start_at: 3.days.from_now,
          end_at: 2.days.from_now
        )

        expect(watchlist).not_to be_valid
      end
    end

    context '開始日時と締切日時が同じ場合' do
      it '無効である' do
        time = 3.days.from_now

        watchlist = build(
          :watchlist,
          start_at: time,
          end_at: time
        )

        expect(watchlist).not_to be_valid
      end
    end

    context '締切日時が過去の場合' do
      it '無効である' do
        watchlist = build(
          :watchlist,
          start_at: nil,
          end_at: 1.day.ago
        )

        expect(watchlist).not_to be_valid
      end
    end

    context 'URLの形式が不正な場合' do
      it '無効である' do
        watchlist = build(
          :watchlist,
          url: 'example.com'
        )

        expect(watchlist).not_to be_valid
      end
    end

    context 'URLの形式が正しい場合' do
      it '有効である' do
        watchlist = build(
          :watchlist,
          url: 'https://example.com'
        )

        expect(watchlist).to be_valid
      end
    end

    context 'URLが空の場合' do
      it '有効である' do
        watchlist = build(:watchlist, url: nil)

        expect(watchlist).to be_valid
      end
    end

    context '種別詳細が20文字の場合' do
      it '有効である' do
        watchlist = build(:watchlist, reception_detail: 'a' * 20)

        expect(watchlist).to be_valid
      end
    end

    context '受付種別の詳細が21文字の場合' do
      it '無効である' do
        watchlist = build(:watchlist, reception_detail: 'a' * 21)

        expect(watchlist).not_to be_valid
      end
    end

    describe '#reception_type_label' do
      it '受付種別が抽選の場合は「抽選」を返す' do
        watchlist = build(
          :watchlist,
          reception_type: :lottery
        )

        result = watchlist.reception_type_label

        expect(result).to eq('抽選')
      end

      it '受付種別が先着の場合は「先着」を返す' do
        watchlist = build(
          :watchlist,
          reception_type: :first_come
        )

        result = watchlist.reception_type_label

        expect(result).to eq('先着')
      end

      it '受付種別が受注販売の場合は「受注販売」を返す' do
        watchlist = build(
          :watchlist,
          reception_type: :made_to_order
        )

        result = watchlist.reception_type_label

        expect(result).to eq('受注販売')
      end

      it '受付種別が指定なしの場合は「指定なし」を返す' do
        watchlist = build(
          :watchlist,
          reception_type: :not_set
        )

        result = watchlist.reception_type_label

        expect(result).to eq('指定なし')
      end
    end
  end

  describe '#reception_label_text' do
    context '受付種別と種別詳細がある場合' do
      it '種別詳細と受付種別を組み合わせた文字列を返す' do
        watchlist = build(
          :watchlist,
          reception_type: :lottery,
          reception_detail: 'FC先行'
        )

        result = watchlist.reception_label_text

        expect(result).to eq('【FC先行抽選】')
      end
    end

    context '種別詳細のみある場合' do
      it '種別詳細のみの文字列を返す' do
        watchlist = build(
          :watchlist,
          reception_type: :not_set,
          reception_detail: 'FC先行'
        )

        result = watchlist.reception_label_text

        expect(result).to eq('【FC先行】')
      end
    end

    context '受付種別のみある場合' do
      it '受付種別のみの文字列を返す' do
        watchlist = build(
          :watchlist,
          reception_type: :lottery,
          reception_detail: nil
        )

        result = watchlist.reception_label_text

        expect(result).to eq('【抽選】')
      end
    end

    context '受付種別も種別詳細もない場合' do
      it 'nilを返す' do
        watchlist = build(
          :watchlist,
          reception_type: :not_set,
          reception_detail: nil
        )

        result = watchlist.reception_label_text

        expect(result).to be_nil
      end
    end
  end

  describe '#display_title' do
    context '受付種別と種別詳細がある場合' do
      it '受付情報を付けたタイトルを返す' do
        watchlist = build(
          :watchlist,
          title: 'チケット申し込み',
          reception_type: :lottery,
          reception_detail: 'FC先行'
        )

        result = watchlist.display_title

        expect(result).to eq('【FC先行抽選】チケット申し込み')
      end
    end

    context '受付種別も種別詳細もない場合' do
      it 'タイトルのみを返す' do
        watchlist = build(
          :watchlist,
          title: 'チケット申し込み',
          reception_type: :not_set,
          reception_detail: nil
        )

        result = watchlist.display_title

        expect(result).to eq('チケット申し込み')
      end
    end
  end

  describe '#save_tags' do
    context '複数のタグ名が入力されている場合' do
      it 'タグを作成してWatchlistに紐付ける' do
        watchlist = create(:watchlist)
        watchlist.tag_names = 'ライブ, チケット'

        watchlist.save_tags

        expect(watchlist.tags.pluck(:name)).to contain_exactly(
          'ライブ',
          'チケット'
        )
      end
    end

    context '区切り文字や空白を含む場合' do
      it 'タグ名を分割して空白を取り除いて保存する' do
        watchlist = create(:watchlist)
        watchlist.tag_names = ' ライブ , チケット、グッズ '

        watchlist.save_tags

        expect(watchlist.tags.pluck(:name)).to contain_exactly(
          'ライブ',
          'チケット',
          'グッズ'
        )
      end
    end

    context '同じ名前のタグがすでに存在する場合' do
      it '既存のタグを再利用する' do
        watchlist = create(:watchlist)
        existing_tag = watchlist.user.tags.create!(name: 'ライブ')
        watchlist.tag_names = 'ライブ'

        expect do
          watchlist.save_tags
        end.not_to change(Tag, :count)

        expect(watchlist.tags).to include(existing_tag)
      end
    end
  end

  describe '.tagged_with' do
    it 'キーワードを含むタグが付いたWatchlistだけを返す' do
      live_watchlist = create(:watchlist)
      goods_watchlist = create(:watchlist)

      live_watchlist.tag_names = 'ライブ'
      live_watchlist.save_tags

      goods_watchlist.tag_names = 'グッズ'
      goods_watchlist.save_tags

      result = Watchlist.tagged_with('ライブ')

      expect(result).to include(live_watchlist)
      expect(result).not_to include(goods_watchlist)
    end
  end

  describe '.upcoming' do
    context '未対応と対応済みの予定がある場合' do
      it '未対応の予定だけを返す' do
        upcoming_watchlist = create(
          :watchlist,
          is_done: false,
          end_at: 3.days.from_now
        )

        done_watchlist = create(
          :watchlist,
          is_done: true,
          end_at: 3.days.from_now
        )

        result = Watchlist.upcoming

        expect(result).to include(upcoming_watchlist)
        expect(result).not_to include(done_watchlist)
      end
    end

    context '締切日時が過ぎた予定がある場合' do
      it '締切日時が過ぎていない予定だけを返す' do
        upcoming_watchlist = create(
          :watchlist,
          is_done: false,
          end_at: 3.days.from_now
        )

        expired_watchlist = create(
          :watchlist,
          is_done: false,
          end_at: 3.days.from_now
        )

        expired_watchlist.update!(
          start_at: 2.days.ago,
          end_at: 1.day.ago
        )

        result = Watchlist.upcoming

        expect(result).to include(upcoming_watchlist)
        expect(result).not_to include(expired_watchlist)
      end
    end

    context '開始前の予定が複数ある場合' do
      it '開始日時が近い順に返す' do
        later_watchlist = create(
          :watchlist,
          start_at: 3.days.from_now,
          end_at: 6.days.from_now
        )

        sooner_watchlist = create(
          :watchlist,
          start_at: 1.day.from_now,
          end_at: 5.days.from_now
        )

        result = Watchlist.upcoming.where(
          id: [later_watchlist.id, sooner_watchlist.id]
        )

        expect(result.to_a).to eq([
                                    sooner_watchlist,
                                    later_watchlist
                                  ])
      end
    end

    context '開始済みの予定が複数ある場合' do
      it '締切日時が近い順に返す' do
        later_watchlist = create(:watchlist)
        sooner_watchlist = create(:watchlist)

        later_watchlist.update!(
          start_at: 2.days.ago,
          end_at: 3.days.from_now
        )

        sooner_watchlist.update!(
          start_at: 3.days.ago,
          end_at: 1.day.from_now
        )

        result = Watchlist.upcoming.where(
          id: [later_watchlist.id, sooner_watchlist.id]
        )

        expect(result.to_a).to eq([
                                    sooner_watchlist,
                                    later_watchlist
                                  ])
      end
    end
  end

  describe '.past' do
    context '対応済みまたは締切日時が過ぎた予定がある場合' do
      it '過去の予定だけを返す' do
        done_watchlist = create(
          :watchlist,
          is_done: true,
          end_at: 3.days.from_now
        )

        expired_watchlist = create(
          :watchlist,
          is_done: false,
          end_at: 3.days.from_now
        )

        expired_watchlist.update!(
          start_at: 2.days.ago,
          end_at: 1.day.ago
        )

        upcoming_watchlist = create(
          :watchlist,
          is_done: false,
          end_at: 3.days.from_now
        )

        result = Watchlist.past

        expect(result).to include(done_watchlist, expired_watchlist)
        expect(result).not_to include(upcoming_watchlist)
      end
    end

    context '複数の過去予定がある場合' do
      it '締切日時が新しい順に返す' do
        older_watchlist = create(:watchlist)
        newer_watchlist = create(:watchlist)

        older_watchlist.update!(
          start_at: 4.days.ago,
          end_at: 3.days.ago
        )

        newer_watchlist.update!(
          start_at: 2.days.ago,
          end_at: 1.day.ago
        )

        result = Watchlist.past.where(
          id: [older_watchlist.id, newer_watchlist.id]
        )

        expect(result.to_a).to eq([
                                    newer_watchlist,
                                    older_watchlist
                                  ])
      end
    end
  end
end
