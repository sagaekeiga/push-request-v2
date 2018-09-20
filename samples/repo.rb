require 'httparty'
require 'base64'

headers = {
  'User-Agent': 'PushRequest',
  'Accept': 'application/vnd.github.symmetra-preview+json'
}

# res = HTTParty.get 'https://api.github.com/repos/sagaekeiga/github-api-sample/branches/master', headers: headers
# puts res
# puts JSON.pretty_generate(JSON.parse(res.body))
# res.each do |file|
#   puts file
# end

res = HTTParty.get 'https://api.github.com/repos/sagaekeiga/github-api-sample/contents/app/models/user.rb?ref=f52dc79570c71b0dc842d556b8fb08dc20827bab', headers: headers

puts JSON.pretty_generate(JSON.parse(res.body))
