class ContentDecorator < ApplicationDecorator
  delegate_all

  def breadcrumbs
    (repo.full_name + '/' + path).gsub!('/', ' / ')
  end

  def decode_by_base64
    Base64.decode64(object.content).force_encoding('UTF-8')
  end
end
