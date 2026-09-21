# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EndNotificationContent do
  describe '.three_days_prior_title' do
    context '締切の予定の場合' do
      it '締切用のタイトルを返す' do
        deadline_watchlist = create(
          :watchlist,
          end_type: :deadline
        )

        title = EndNotificationContent.three_days_prior_title(deadline_watchlist)

        expect(title).to eq('締め切りの3日前です')
      end
    end

    context '終了の予定の場合' do
      it '終了用のタイトルを返す' do
        ending_watchlist = create(
          :watchlist,
          end_type: :ending
        )

        title = EndNotificationContent.three_days_prior_title(ending_watchlist)

        expect(title).to eq('終了まであと3日です')
      end
    end
  end

  describe '.three_days_prior_content' do
    context '締め切りの予定の場合' do
      it '締め切りの文言を返す' do
        deadline_watchlist = create(
          :watchlist,
          end_type: :deadline
        )

        content = EndNotificationContent.three_days_prior_content(deadline_watchlist)

        expect(content).to eq("気になっている「#{deadline_watchlist.display_title}」の締め切りまであと3日です。" \
          '忘れないうちにチェックしてみませんか？')
      end
    end

    context '終了の予定の場合' do
      it '終了の文言を返す' do
        ending_watchlist = create(
          :watchlist,
          end_type: :ending
        )

        content = EndNotificationContent.three_days_prior_content(ending_watchlist)

        expect(content).to eq("気になっている「#{ending_watchlist.display_title}」の終了まであと3日です。" \
          '終了前に、もう一度チェックしてみませんか？')
        
      end
    end
  end

  describe '.day_before_title' do
    context '締め切りの予定の場合' do
      it '締め切りのタイトルを返す' do
        deadline_watchlist = create(
          :watchlist,
          end_type: :deadline
        )

        title = EndNotificationContent.day_before_title(deadline_watchlist)

        expect(title).to eq('明日締め切りです')
      end
    end

    context '終了の予定の場合' do
      it '終了のタイトルを返す' do
        ending_watchlist = create(
          :watchlist,
          end_type: :ending
        )

        title = EndNotificationContent.day_before_title(ending_watchlist)

        expect(title).to eq('終了は明日です')
      end
    end
  end

  describe '.day_before_content' do
    context '締め切りの予定の場合' do
      it '締め切りの文言を返す' do
        deadline_watchlist = create(
          :watchlist,
          end_type: :deadline
        )

        content = EndNotificationContent.day_before_content(deadline_watchlist)

        expect(content).to eq("気になっている「#{deadline_watchlist.display_title}」の締め切りは明日です。" \
          '大切な予定を見逃さないようにご確認ください。')
      end
    end

    context '終了の予定の場合' do
      it '終了の文言を返す' do
        ending_watchlist = create(
          :watchlist,
          end_type: :ending
        )

        content = EndNotificationContent.day_before_content(ending_watchlist)

        expect(content).to eq("気になっている「#{ending_watchlist.display_title}」の終了は明日です。" \
          '終了前に、もう一度チェックしてみませんか？')
      end
    end
  end

  describe '.deadline_same_day_title' do
    context '締め切りの予定の場合' do
      it '締め切りのタイトルを返す' do
        deadline_watchlist = create(
          :watchlist,
          end_type: :deadline
        )

        title = EndNotificationContent.deadline_same_day_title(deadline_watchlist)

        expect(title).to eq('締め切りは本日です')
      end
    end

    context '終了の予定の場合' do
      it '終了のタイトルを返す' do
        ending_watchlist = create(
          :watchlist,
          end_type: :ending
        )

        title = EndNotificationContent.deadline_same_day_title(ending_watchlist)

        expect(title).to eq('終了は本日です')
      end
    end
  end

  describe '.deadline_same_day_content' do
    context '締め切りの予定の場合' do
      it '締め切りの文言を返す' do
        deadline_watchlist = create(
          :watchlist,
          end_type: :deadline
        )

        content = EndNotificationContent.deadline_same_day_content(deadline_watchlist)

        expect(content).to eq("気になっている「#{deadline_watchlist.display_title}」の締め切りは本日です。" \
          '大切な予定を見逃さないようにご確認ください。')
      end
    end

    context '終了の予定の場合' do
      it '終了の文言を返す' do
        ending_watchlist = create(
          :watchlist,
          end_type: :ending
        )

        content = EndNotificationContent.deadline_same_day_content(ending_watchlist)

        expect(content).to eq("気になっている「#{ending_watchlist.display_title}」の終了は本日です。" \
          '終了前に、もう一度チェックしてみませんか？')
      end
    end
  end

  describe '.notification_title_for' do
    context '終了用のタイトルが設定されていない場合' do
      it '通常のタイトルを返す' do
        watchlist = create(
          :watchlist,
          end_type: :ending
        )

        config = {
          title: '開始まであと10分です'
        }

        title = EndNotificationContent.notification_title_for(watchlist, config)

        expect(title).to eq('開始まであと10分です')
      end
    end

    context '終了用のタイトルが設定されている場合' do
      it '締め切りの場合、締め切りのタイトルを返す' do
        watchlist = create(
          :watchlist,
          end_type: :deadline
        )

        config = {
          title: '締め切りまであと3時間です',
          ending_title: '終了まであと3時間です'
        }

        title = EndNotificationContent.notification_title_for(watchlist, config)

        expect(title).to eq('締め切りまであと3時間です')
      end

      it '終了の場合、終了のタイトルを返す' do
        watchlist = create(
          :watchlist,
          end_type: :ending
        )

        config = {
          title: '締め切りまであと3時間です',
          ending_title: '終了まであと3時間です'
        }

        title = EndNotificationContent.notification_title_for(watchlist, config)

        expect(title).to eq('終了まであと3時間です')
      end
    end
  end

  describe '.notification_message_for' do
    context '終了用の文言が設定されていない場合' do
      it '通常の文言を返す' do
        watchlist = create(
          :watchlist,
          end_type: :ending
        )

        config = {
          message: "開始まであと10分です。\n\nまもなく始まります。\n詳細をご確認ください。"
        }

        message = EndNotificationContent.notification_message_for(watchlist, config)

        expect(message).to eq( "開始まであと10分です。\n\nまもなく始まります。\n詳細をご確認ください。")
      end
    end

    context '終了用の文言が設定されている場合' do
      it '締め切りの場合、締め切りの文言を返す' do
        watchlist = create(
          :watchlist,
          end_type: :deadline
        )

        config = {
          message: "締め切りまであと3時間です。\n\n大切な予定を見逃さないようご確認ください。",
          ending_message: "終了まであと3時間です。\n\n終了前に、もう一度チェックしてみませんか？"
        }

        message = EndNotificationContent.notification_message_for(watchlist, config)

        expect(message).to eq("締め切りまであと3時間です。\n\n大切な予定を見逃さないようご確認ください。")
      end

      it '終了の場合、終了の文言を返す' do
        watchlist = create(
          :watchlist,
          end_type: :ending
        )

        config = {
          message: "締め切りまであと3時間です。\n\n大切な予定を見逃さないようご確認ください。",
          ending_message: "終了まであと3時間です。\n\n終了前に、もう一度チェックしてみませんか？"
        }

        message = EndNotificationContent.notification_message_for(watchlist, config)

        expect(message).to eq("終了まであと3時間です。\n\n終了前に、もう一度チェックしてみませんか？")
      end
    end
  end
end