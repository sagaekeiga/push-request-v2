module GenToken
  extend ActiveSupport::Concern

  included do
    friendly_id :token
    before_create do
      #
      # 一意のトークンを作成する
      #
      loop do
        self.token = SecureRandom.hex(10)
        break if self.valid?
      end
    end
  end
end
