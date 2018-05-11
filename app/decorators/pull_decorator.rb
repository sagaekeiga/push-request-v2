class PullDecorator < Draper::Decorator
  # GitHub上のプルリクエストへのリンクを返す
  def remote_url
    Settings.github.web_domain + object.repo.full_name + '/pull/' + object.number&.to_s
  end
end
