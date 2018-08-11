# encoding: UTF-8

xml.instruct! :xml, :version => '1.0'
xml.rss('version': '2.0', 'xmlns:dc': 'http://purl.org/dc/elements/1.1/') do
  xml.channel do
    xml.title 'PushRequest'
    xml.description 'Pushrequestのフィードです'
    xml.link 'https://push-request-v2-staging.herokuapp.com/'
    @pulls.each do |pull|
      xml.item do
        xml.title pull.title
        xml.description do
          xml.cdata! HTML_Truncator.truncate(pull.body, 10).html_safe
        end
        xml.pubDate pull.created_at
        xml.guid reviewers_pull_url(pull.token)
        xml.link reviewers_pull_url(pull.token)
      end
    end
  end
end
