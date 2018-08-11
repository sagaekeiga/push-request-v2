# encoding: UTF-8

xml.instruct! :xml, :version => '1.0'
xml.rss('version': '2.0', 'xmlns:dc': 'http://purl.org/dc/elements/1.1/') do
  xml.channel do
    xml.title 'ああああああ'
    xml.description 'いいいいいいい'
    xml.link 'うううううう'
    @pulls.each do |pull|
      xml.item do
        xml.title pull.title
        xml.description do
          xml.cdata! HTML_Truncator.truncate(pull.to_html, 1).html_safe
        end
        xml.pubDate pull.created_at
        xml.guid reviewers_pull_path(pull.token)
        xml.link reviewers_pull_path(pull.token)
      end
    end
  end
end
