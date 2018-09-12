class ContentDecorator < ApplicationDecorator
  delegate_all

  def breadcrumbs
    (repo.full_name + '/' + path).gsub!('/', ' / ')
  end
end
