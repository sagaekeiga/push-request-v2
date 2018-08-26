module Github
  class Request
    include HTTParty

    class << self

      # レビュー送信
      def github_exec_review!(params, pull)
        _request params, sub_url(:review, pull), pull.repo.installation_id, :review
      end

      # コメント送信
      def github_exec_issue_comment!(params, pull)
        _request params, sub_url(:issue_comment, pull), pull.repo.installation_id, :issue_comment
      end

      private

      #
      # リクエストの送信処理
      #
      # @param [String] sub_url github api urlの後続のURL ex. /repos/:owner/:repo/pulls/comments/:comment_id
      # @param [Hash] params 送信パラメータ { path: xxxx, position: yyyy, body: zzzz }
      #
      def _request(params, sub_url, installation_id, event)
        headers = {
          'User-Agent': 'PushRequest',
          'Authorization': "token #{get_access_token(installation_id)}",
          'Accept': set_accept(event)
        }

        res = post Settings.github.api_domain + sub_url, headers: headers, body: params

        unless res.code == success_code(event)
          logger.error "[Github][#{event}] responseCode => #{res.code}"
          logger.error "[Github][#{event}] responseMessage => #{res.message}"
          logger.error "[Github][#{event}] subUrl => #{sub_url}"
        end
        res
      end

      def get_access_token(installation_id)
        request_url = Settings.github.request.access_token_uri + installation_id.to_s + '/access_tokens'
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
          return Settings.github.request.header.accept.review
        when :issue_comment
          return Settings.github.request.header.accept.issue_comment
        end
      end

      # 成功時のレスポンスコード
      def success_code(event)
        case event
        when :review
          return Settings.res.code.success
        when :issue_comment
          return Settings.res.code.created
        end
      end

      def sub_url(event, pull)
        case event
        when :review
          return "repos/#{pull.repo_full_name}/pulls/#{pull.number}/reviews"
        when :issue_comment
          return "repos/#{pull.repo_full_name}/issues/#{pull.number}/comments"
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
