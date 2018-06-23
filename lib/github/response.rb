module GmoPaymentGateway
  class Response
    class << self
      def receive_api_response_in_json_format_on(target_uri, recource)
        parsed_uri = URI.parse target_uri
        target_request = generate_request_according_to(parsed_uri, "token #{recource.github_account.access_token}", 'get')
        req_options = {
          use_ssl: parsed_uri.scheme == 'https'
        }

        response = Net::HTTP.start(parsed_uri.hostname, parsed_uri.port, req_options) do |http|
          http.request(target_request)
        end
        JSON.load(response.body)
      end
