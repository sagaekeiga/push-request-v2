require 'bundler'
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


## Oauth
uri = URI.parse "https://github.com/login/oauth/authorize?client_id=Iv1.d8707dc6ca494ac7&redirect_uri=http://push-request-v2.test/auth/github/callback"
request = Net::HTTP::Get.new(uri)
request["Accept"] = "application/vnd.github.machine-man-preview+json"

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

p response

## Get Repository ##
# uri = URI.parse("https://api.github.com/installation/repositories")
# request = Net::HTTP::Get.new(uri)
# request["Authorization"] = "token #{json['token']}"
# request["Accept"] = "application/vnd.github.machine-man-preview+json"
#
# req_options = {
#   use_ssl: uri.scheme == "https",
# }
#
# response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
#   http.request(request)
# end
#
# puts JSON.pretty_generate(JSON.load(response.body))
#
# # Get Skill
# JSON.load(response.body)['repositories'].each do |repo|
#   p '----------------------------------'
#   p repo['name']
#   p repo['language']
#   p '----------------------------------'
# end

## Get List Repositories ##
# p 'token'
# p json['token']
# p 'token'
# uri = URI.parse("https://api.github.com/installation/repositories")
# request = Net::HTTP::Get.new(uri)
# request["Authorization"] = "token #{json['token']}"
# request["Accept"] = "application/vnd.github.machine-man-preview+json"
#
# req_options = {
#   use_ssl: uri.scheme == "https",
# }
#
# response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
#   http.request(request)
# end
#
# puts JSON.pretty_generate(JSON.load(response.body))
#
# # Get Skill
# JSON.load(response.body)['repositories'].each do |repo|
#   p '----------------------------------'
#   p repo['name']
#   p repo['language']
#   p '----------------------------------'
# end


# Get Pullrequest ##
uri = URI.parse("https://api.github.com/repos/sagaeminami/original/pulls")
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

## Get PRFile ##
# uri = URI.parse("https://api.github.com/repos/sagaekeiga/github-api-sample/pulls/1/files")
# request = Net::HTTP::Get.new(uri)
# request["Authorization"] = "token #{json['token']}"
# request["Accept"] = "application/vnd.github.machine-man-preview+json"
#
# req_options = {
#   use_ssl: uri.scheme == "https",
# }
#
# response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
#   http.request(request)
# end
#
#
# puts JSON.pretty_generate(JSON.load(response.body))

## Get PRFile ##
# uri = URI.parse("https://api.github.com/repos/sagaekeiga/github-api-sample/pulls/24/comments")
# request = Net::HTTP::Get.new(uri)
# request["Authorization"] = "token #{json['token']}"
# request["Accept"] = "application/vnd.github.machine-man-preview+json"
#
# req_options = {
#   use_ssl: uri.scheme == "https",
# }
#
# response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
#   http.request(request)
# end
#
#
# puts JSON.pretty_generate(JSON.load(response.body))

## POST Review ##
# uri = URI.parse("https://api.github.com/repos/sagaekeiga/github-api-sample/pulls/1/reviews")
# request = Net::HTTP::Post.new(uri)
# request["Authorization"] = "token #{json['token']}"
# request["Accept"] = "application/vnd.github.machine-man-preview+json"
# request.body =
#   {
#     'body': 'hoge',
#     'event': 'COMMENT',
#     'comments': [
#       {
#         'path': 'app/assets/javascripts/welcome.coffee',
#         'position': 3,
#         'body': 'hoge'
#       }
#     ]
#   }.to_json
#
# req_options = {
#   use_ssl: uri.scheme == "https",
# }
#
# response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
#   http.request(request)
# end
#
# p response.body
