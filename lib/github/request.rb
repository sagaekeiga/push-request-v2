module Github
  class Request
    include HTTParty

    class << self
      # POST レビュー送信
      def github_exec_review!(params, pull)
        _post sub_url(:review, pull), pull.repo.installation_id, :review, params
      end

      # POST コメント送信
      def github_exec_issue_comment!(params, pull)
        _post sub_url(:issue_comment, pull), pull.repo.installation_id, :issue_comment, params
      end

      # POST リプライ送信
      def github_exec_review_comment!(params, pull)
        _post sub_url(:review_comment, pull), pull.repo.installation_id, :review_comment, params
      end

      # GET レポジトリファイルの取得
      def github_exec_fetch_repo_contents!(repo, path = '')
        _get "repos/#{repo.full_name}/contents/#{path}", repo.installation_id, :content
      end

      def github_exec_fetch_changed_file_content!(repo, content_url)
        headers = {
          'User-Agent': 'PushRequest',
          'Authorization': "token #{get_access_token(repo.installation_id)}",
          'Accept': set_accept(:content)
        }

        res = get content_url, headers: headers

        unless res.code == success_code(:content)
          logger.error "[Github][#{event}] responseCode => #{res.code}"
          logger.error "[Github][#{event}] responseMessage => #{res.message}"
          logger.error "[Github][#{event}] subUrl => #{sub_url}"
        end
        res
      end

      # GET プルリクエスト取得
      def github_exec_fetch_pulls!(repo)
        _get sub_url_for(repo, :pull), repo.installation_id, :pull
      end

      # GET ISSUE取得
      def github_exec_fetch_issues!(repo)
        _get sub_url_for(repo, :issue), repo.installation_id, :issue
      end

      # GET コミット取得
      def github_exec_fetch_commits!(pull)
        _get sub_url(:commit, pull), pull.repo.installation_id, :commit
      end

      # GET 前のコミットのファイル差分取得
      # ref: https://developer.github.com/v3/repos/commits/#get-a-single-commit
      def github_exec_fetch_changed_files!(commit)
        _get "repos/#{commit.pull.repo_full_name}/commits/#{commit.sha}", commit.pull.repo.installation_id, :changed_file
      end

      # GET ファイル差分取得
      # ref: https://developer.github.com/v3/repos/commits/#compare-two-commits
      def github_exec_fetch_diff!(pull)
        _get "repos/#{pull.repo_full_name}/compare/#{pull.base_label}...#{pull.head_label}", pull.repo.installation_id, :diff
      end

      # GET レポジトリのmasterのshaを取得
      def github_exec_fetch_repo_sha!(repo)
        _get "repos/#{repo.full_name}/branches/master", repo.installation_id, :repo_sha
      end

      # GET redameの取得
      def github_exec_fetch_readme(repo)
        _get sub_url_for(repo, :readme), repo.installation_id, :readme
      end

      def github_exec_fetch_file_content!(repo, content)
        _get "repos/#{repo.full_name}/contents/#{content.path}?ref=#{repo.sha}", repo.installation_id, :file_content
      end

      private

      #
      # リクエストの送信処理
      #
      # @param [String] sub_url github api urlの後続のURL ex. /repos/:owner/:repo/pulls/comments/:comment_id
      # @param [Hash] params 送信パラメータ { path: xxxx, position: yyyy, body: zzzz }
      #
      def _post(sub_url, installation_id, event, params)
        headers = {
          'User-Agent': 'PushRequest',
          'Authorization': "token #{get_access_token(installation_id)}",
          'Accept': set_accept(event)
        }

        res = post Settings.api.github.api_domain + sub_url, headers: headers, body: params

        unless res.code == success_code(event)
          logger.error "[Github][#{event}] responseCode => #{res.code}"
          logger.error "[Github][#{event}] responseMessage => #{res.message}"
          logger.error "[Github][#{event}] subUrl => #{sub_url}"
        end
        res
      end

      def _get(sub_url, installation_id, event)
        headers = {
          'User-Agent': 'PushRequest',
          'Authorization': "token #{get_access_token(installation_id)}",
          'Accept': set_accept(event)
        }

        res = get Settings.api.github.api_domain + sub_url, headers: headers

        unless res.code == success_code(event)
          logger.error "[Github][#{event}] responseCode => #{res.code}"
          logger.error "[Github][#{event}] responseMessage => #{res.message}"
          logger.error "[Github][#{event}] subUrl => #{sub_url}"
        end
        res
      end

      def get_access_token(installation_id)
        request_url = Settings.api.github.request.access_token_uri + installation_id.to_s + '/access_tokens'
        headers = {
          'User-Agent': 'PushRequest',
          'Authorization': "Bearer #{get_jwt}",
          'Accept': set_accept(:get_access_token)
        }

        res = post request_url, headers: headers

        res = JSON.load(res.body)
        access_token = res['token']
        access_token
      end

      def get_jwt
        # Private key contents
        private_pem = Rails.env.production? ? ENV['PRIVATE_PEM'] : File.read(ENV['PATH_TO_PEM_FILE'])
        private_key = OpenSSL::PKey::RSA.new(private_pem)
        # Generate the JWT
        payload = {
          # issued at time
          iat: Time.now.to_i,
          # JWT expiration time (10 minute maximum)
          exp: Time.now.to_i + (10 * 60),
          # GitHub App's identifier
          iss: ENV['GITHUB_APP_PAYLOAD_ISS_ID']
        }

        jwt = JWT.encode payload, private_key, 'RS256'
        jwt
      end

      # イベントに対応するacceptを返す
      def set_accept(event)
        case event
        when :review, :get_access_token
          return Settings.api.github.request.header.accept.machine_man_preview_json
        when :issue_comment
          return Settings.api.github.request.header.accept.machine_man_preview
        when :changed_file, :pull, :content, :issue, :commit, :diff, :repo_sha, :readme, :file_content
          return Settings.api.github.request.header.accept.symmetra_preview_json
        when :review_comment
          return Settings.api.github.request.header.accept.squirrel_girl_preview
        end
      end

      # 成功時のレスポンスコード
      def success_code(event)
        case event
        when :issue_comment, :changed_file, :pull, :review_comment
          return Settings.api.created.status.code
        when :content, :commit, :issue, :diff, :review, :repo_sha, :readme, :file_content
          return Settings.api.success.status.code
        end
      end

      def sub_url(event, pull)
        case event
        when :review
          return "repos/#{pull.repo_full_name}/pulls/#{pull.number}/reviews"
        when :issue_comment
          return "repos/#{pull.repo_full_name}/issues/#{pull.number}/comments"
        when :changed_file
          return "repos/#{pull.repo_full_name}/pulls/#{pull.number}/files"
        when :review_comment
          return "repos/#{pull.repo_full_name}/pulls/#{pull.number}/comments"
        when :commit
          return "repos/#{pull.repo_full_name}/pulls/#{pull.number}/commits"
        end
      end

      def sub_url_for(repo, event)
        case event
        when :issue
          return "repos/#{repo.full_name}/issues"
        when :pull
          return "repos/#{repo.full_name}/pulls"
        when :readme
          return "repos/#{repo.full_name}/readme"
        end
      end

      #
      # ログをRailsのものを流用する
      #
      # @return [Logger]
      #
      def logger
        Rails.logger
      end
    end
  end
end
