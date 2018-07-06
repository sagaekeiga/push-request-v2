module Github
  class Request
    include HTTParty
    base_uri Settings.aossms.api_url

    class << self
      #
      # ショートメッセージ送信
      #
      # - message      : 最大70文字の文字列
      # - phone_number : 送信先電話番号 日本国内形式(070xxxxxxxx/080xxxxxxxx/090xxxxxxxx)、国際電話番号形式も可
      #
      # @param [Hash] params
      #
      # @return [Hash]
      #
      def github_exec_review_comment!(params)
        _request 'mt.json', params
      end

      # レビュー送信
      def github_exec_review!(params, review)
        sub_url = "https://api.github.com/repos/#{pull.repo_full_name}/pulls/#{pull.number}/reviews"
        _request
      end

      private

      #
      # リクエストの送信処理
      #
      # @param [String] endpoint エンドポイント ex. mt.json
      # @param [Hash] params 送信パラメータ { message: xxxxxx, phone_number: xxxyyyyzzzz}
      #
      def _request(sub_url, params)
        request_params = {
          token:       ENV['AOS_ACCESS_TOKEN'],
          clientId:    ENV['AOS_CLIENT_ID'],
          smsCode:     ENV['AOS_SMS_CODE'],
          message:     params[:message],
          phoneNumber: params[:phone_number],
          charset:     'utf8'
        }

        return {} if ENV['DO_NOT_REQUEST'].present?

        res = post Settings.github.api_domain + endpoint, body: request_params
        unless res['responseCode'] == 0
          logger.error "[Github][#{endpoint}] responseCode => #{res['responseCode']}"
          logger.error "[Github][#{endpoint}] responseMessage => #{res['responseMessage']}"
          logger.error "[Github][#{endpoint}] phoneNumber => #{res['phoneNumber']}"
          logger.error "[Github][#{endpoint}] smsMessage => #{res['smsMessage']}"
        end
        res
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
