module ApplicationHelper
  def date_format(datetime)
    time_ago_in_words(datetime) + '前' if datetime
  end
end
