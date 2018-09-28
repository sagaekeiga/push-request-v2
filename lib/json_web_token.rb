require 'jwt'
#
# JSON Web Tokenを利用するためのクラス
#
class JsonWebToken
 def self.encode(payload)
   payload = payload.dup
   JWT.encode(payload, Rails.application.secrets.secret_key_base)
 end

 def self.decode(token)
   JWT.decode(token, Rails.application.secrets.secret_key_base)
 end
end
