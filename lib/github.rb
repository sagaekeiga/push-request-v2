module Github
  # @TODO ファイル名をリネーム
  class << self
    def generate_request_according_to(parsed_uri, authorization_element, method)
      request = method == 'get' ? Net::HTTP::Get.new(parsed_uri) : Net::HTTP::Post.new(parsed_uri)
      request['Authorization'] = authorization_element
      request['Accept'] = Settings.github.request.header.accept
      request
    end
  end
end
