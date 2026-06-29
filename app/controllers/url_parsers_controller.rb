class UrlParsersController < ApplicationController
  def fetch_title
    url = params[:url]

    if url.blank?
      return render json: { error: 'URLが入力されていません' }, status: :bad_request
    end

    begin
      # タイムアウトを5秒に設定して安全に解析
      page = MetaInspector.new(url, connection_timeout: 5, read_timeout: 5, retries: 1)
      title = page.best_title

      if title.present?
        render json: { title: title }
      else
        render json: { error: 'タイトルが取得できませんでした' }, status: :unprocessable_entity
      end

    rescue MetaInspector::Error, StandardError => e
      logger.error "URL解析エラー: #{e.message}"
      render json: { error: 'タイトルが取得できませんでした' }, status: :unprocessable_entity
    end
  end
end