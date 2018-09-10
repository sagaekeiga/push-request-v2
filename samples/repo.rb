require 'httparty'
require 'base64'

headers = {
  'User-Agent': 'PushRequest',
  'Accept': 'application/vnd.github.symmetra-preview+json'
}

res = HTTParty.get 'https://api.github.com/repos/sagaekeiga/github-api-sample/pulls/31/files', headers: headers
puts res
res.each do |file|
  puts file
end
