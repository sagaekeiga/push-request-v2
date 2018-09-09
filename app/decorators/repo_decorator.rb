class RepoDecorator < ApplicationDecorator
  delegate_all
  # GitHub上のレポジトリへのリンクを返す
  def remote_url
    Settings.github.web_domain + object.full_name
  end

  def btn_by_status
    case status
    when 'hidden'
      'btn-outline-primary'
    when 'showing'
      'btn-outline-danger'
    end
  end

  def text_by_status
    case status
    when 'hidden'
      'このレポジトリ全体を公開する'
    when 'showing'
      'このレポジトリ全体を非公開にする'
    end
  end
end
