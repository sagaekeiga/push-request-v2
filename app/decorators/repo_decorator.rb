class RepoDecorator < Draper::Decorator
  # GitHub上のレポジトリへのリンクを返す
  def remote_repo_url
    Settings.github.web_domain + object.full_name
  end
end
