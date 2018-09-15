require 'httparty'
require 'base64'

headers = {
  'User-Agent': 'PushRequest',
  'Accept': 'application/vnd.github.symmetra-preview+json'
}

res = HTTParty.get 'https://api.github.com/repos/sagaekeiga/github-api-sample/issues', headers: headers
# puts res
res.each do |file|
  next if file.has_key?('pull_request')
  puts file
end
