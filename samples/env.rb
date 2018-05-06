require 'openssl'
require 'jwt'
require 'net/http'
require 'uri'
require 'dotenv'
require 'json'

Dotenv.load



# Private key contents
private_pem = File.read(ENV['PATH_TO_PEM_FILE'])
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

jwt = JWT.encode payload, private_key, "RS256"
p '【GET JSON WEB TOKEN】'
puts jwt



## Get access token ##
uri = URI.parse "https://api.github.com/installations/#{ENV['GITHUB_APP_INSTALLATION_ID']}/access_tokens"
request = Net::HTTP::Post.new(uri)
request["Authorization"] = "Bearer #{jwt}"
request["Accept"] = "application/vnd.github.machine-man-preview+json"

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

p '【GET TOKEN】'
p json = JSON.load(response.body)
p json['token']



## Get Repository ##
uri = URI.parse("https://api.github.com/installation/repositories")
request = Net::HTTP::Get.new(uri)
request["Authorization"] = "token #{json['token']}"
request["Accept"] = "application/vnd.github.machine-man-preview+json"

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

puts JSON.pretty_generate(JSON.load(response.body))

uri = URI.parse("https://api.github.com/repos/reviewers-prototype/116569462/pulls")
request = Net::HTTP::Get.new(uri)
request["Authorization"] = "token #{json['token']}"
request["Accept"] = "application/vnd.github.machine-man-preview+json"

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

puts JSON.pretty_generate(JSON.load(response.body))
