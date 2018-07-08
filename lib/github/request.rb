module Github
  class Request
    include HTTParty

    class << self

      # レビュー送信
      def github_exec_review!(params, pull)
        sub_url = "repos/#{pull.repo_full_name}/pulls/#{pull.number}/reviews"
        installation_id = pull.repo.installation_id
        _request params, sub_url, installation_id
      end

      private

      #
      # リクエストの送信処理
      #
      # @param [String] sub_url github api urlの後続のURL ex. /repos/:owner/:repo/pulls/comments/:comment_id
      # @param [Hash] params 送信パラメータ { path: xxxx, position: yyyy, body: zzzz }
      #
      def _request(params, sub_url, installation_id)
        headers = {
          'User-Agent': 'PushRequest',
          'Authorization': "token #{get_access_token(installation_id)}",
          'Accept': Settings.github.request.header.accept
        }

        res = post Settings.github.api_domain + sub_url, headers: headers, body: params

        unless res.code == '200'
          logger.error "[Github][#{sub_url}] responseCode => #{res['responseCode']}"
          logger.error "[Github][#{sub_url}] responseMessage => #{res['responseMessage']}"
          logger.error "[Github][#{sub_url}] phoneNumber => #{res['phoneNumber']}"
          logger.error "[Github][#{sub_url}] smsMessage => #{res['smsMessage']}"
        end
        res
      end

      def get_access_token(installation_id)
        request_url = Settings.github.request.access_token_uri + installation_id.to_s + '/access_tokens'
        headers = {
          'User-Agent': 'PushRequest',
          'Authorization': "Bearer #{get_jwt}",
          'Accept': Settings.github.request.header.accept
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
