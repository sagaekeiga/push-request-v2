module Synchronizes
  class << self
    def create_or_update
      # レポジトリ取得
      Repo.check_installation_repositories(github_account)
      # レポジトリ作成 or 更新 or 削除
      # PR取得
      # PR作成 or 更新 or 削除
    end

  end
end
