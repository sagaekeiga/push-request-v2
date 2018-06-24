module Github
  class Request
    class << self
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

      def get_access_token(installation_id)
        parsed_uri = URI.parse Settings.github.request.access_token_uri + installation_id.to_s + '/access_tokens'
        target_request = Net::HTTP::Post.new(parsed_uri)
        p "==========================="
        p Github::Request.get_jwt
        p "==========================="
        target_request['Authorization'] = "Bearer #{Github::Request.get_jwt}"
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
    end
  end
end
