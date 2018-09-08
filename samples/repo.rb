require 'httparty'
require 'base64'

headers = {
  'User-Agent': 'PushRequest',
  'Accept': 'application/vnd.github.symmetra-preview+json'
}

res = HTTParty.get 'https://api.github.com/repos/sagaekeiga/push-request-v2/contents/.babelrc', headers: headers
puts res
# puts Base64.decode64(res['content'])
# res.each do |file|
#   puts file
#   res = HTTParty.get "https://api.github.com/repos/sagaekeiga/github-api-sample/contents/#{file['path']}", headers: headers
#   res.each do |file_2|
#     puts file_2
#   end
# end
