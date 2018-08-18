require 'httparty'

headers = {
  'User-Agent': 'PushRequest',
  'Accept': 'application/vnd.github.symmetra-preview+json'
}

res = HTTParty.get 'https://api.github.com/repos/plataformatec/devise/pulls', headers: headers
res.each do |pull|
  puts pull['id']
end
