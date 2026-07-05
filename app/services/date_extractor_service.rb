# frozen_string_literal: true

class DateExtractorService
  # 各種正規表現の定義
  # 1. 基本となる日時のパターン（年、曜日、時間はオプション）
  DATE_TIME_PATTERN = %r{(?:\d{4}[年/.-])?\d{1,2}(?:/|月)\d{1,2}日?(?:[(（][^）)]+[)）])?(?:\s*\d{1,2}[:時]\d{2}分?)?}

  # 2. 期間を繋ぐ記号
  RANGE_SYMBOL = /\s*(?:〜|～|-|─|ー|to)\s*/

  # 3. 期間全体を捉える正規表現
  RANGE_PATTERN = /(#{DATE_TIME_PATTERN})#{RANGE_SYMBOL}(#{DATE_TIME_PATTERN})/

  def initialize(text)
    @text = text
  end

  def call
    return [] if @text.blank?

    results = []
    temporary_text = @text.dup

    # 1. 期間の抽出
    extract_ranges(temporary_text, results)

    # 2. 単発日時の抽出
    extract_single_dates(temporary_text, results)

    results
      .uniq { |r| r[:value] }
      .sort_by { |r| r[:value] || '' }
  end

  private

  def extract_ranges(text, results)
    text.scan(RANGE_PATTERN) do |start_str, end_str|
      results << { label: "開始: #{start_str}", value: parse_to_datetime_string(start_str) }
      results << { label: "締切: #{end_str}", value: parse_to_datetime_string(end_str) }
    end
    text.gsub!(RANGE_PATTERN, '')
  end

  def extract_single_dates(text, results)
    text.scan(DATE_TIME_PATTERN) do |match_str|
      next if match_str.length < 3

      results << { label: "候補: #{match_str}", value: parse_to_datetime_string(match_str) }
    end
  end

  def parse_to_datetime_string(str)
    clean_str = sanitize_date_string(str)
    clean_str = normalize_datetime_format(clean_str)

    Time.zone.parse(clean_str)&.strftime('%Y-%m-%dT%H:%M')
  rescue StandardError
    nil
  end

  # 文字列のクレンジング（曜日除去、記号の統一）
  def sanitize_date_string(str)
    str.gsub(/[(（][^）)]+[)）]/, '')
       .gsub(/[年月日.-]/, '/')
       .gsub(/[時分]/, ':')
       .gsub(%r{/+}, '/')
       .strip
  end

  # 年や時間の補完ロジック
  def normalize_datetime_format(str)
    str = "#{Time.current.year}/#{str}" unless str.match?(/\A\d{4}/)
    str = "#{str} 00:00" unless str.match?(/\d{1,2}:\d{2}/)
    str
  end
end
