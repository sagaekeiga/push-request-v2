module Github
  class Response
    class << self
      def receive_api_response_in_json_format_on(target_uri, installation_id)
        parsed_uri = URI.parse target_uri
        target_request = Github.generate_request_according_to(parsed_uri, "token #{Github::Request.get_access_token(installation_id)}", 'get')
        req_options = {
          use_ssl: parsed_uri.scheme == 'https'
        }

        response = Net::HTTP.start(parsed_uri.hostname, parsed_uri.port, req_options) do |http|
          http.request(target_request)
        end
        JSON.load(response.body)
      end
    end
  end
end
