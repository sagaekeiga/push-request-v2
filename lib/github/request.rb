module GmoPaymentGateway
  class Request
    class << self
      def  get_jwt
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

      def get_access_token
        parsed_uri = URI.parse Settings.github.request.access_token_uri
        target_request = Net::HTTP::Post.new(parsed_uri)
        target_request['Authorization'] = "Bearer #{get_jwt}"
        target_request['Accept'] = Settings.github.request.header.accept

        req_options = {
          use_ssl: parsed_uri.scheme == 'https'
        }

        response = Net::HTTP.start(parsed_uri.hostname, parsed_uri.port, req_options) do |http|
          http.request(target_request)
        end
        # p JSON.load(response.body)
        response_in_json_format = JSON.load(response.body)
        access_token = response_in_json_format['token']
        access_token
      end

      def receive_api_request_in_json_format_on(target_uri, body, recource)
        parsed_uri = URI.parse target_uri
        target_request = generate_request_according_to(parsed_uri, "token #{get_access_token}", 'post')
        target_request.body = body

        req_options = {
          use_ssl: parsed_uri.scheme == 'https'
        }

        response = Net::HTTP.start(parsed_uri.hostname, parsed_uri.port, req_options) do |http|
          http.request(target_request)
        end
        response
      end

      def generate_request_according_to(parsed_uri, authorization_element, method)
        request = method == 'get' ? Net::HTTP::Get.new(parsed_uri) : Net::HTTP::Post.new(parsed_uri)
        request['Authorization'] = authorization_element
        request['Accept'] = Settings.github.request.header.accept
        request
      end
    end
  end
end
