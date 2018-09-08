module ApplicationHelper
  #
  # デフォルトメタタグ設定
  #
  def default_meta_tags
    {
      site: Settings.site.name,
      reverse: true,
      title: Settings.site.page_title,
      description: Settings.site.page_description,
      keywords: Settings.site.page_keywords,
      canonical: request.original_url,
      og: {
        title: :title,
        description: Settings.site.page_description,
        type: Settings.site.meta.ogp.type,
        url: request.original_url,
        image: image_url(Settings.site.meta.ogp.image_path),
        site_name: Settings.site.name,
        description: :description,
        locale: 'ja_JP'
      }
    }
  end

  def date_format(datetime)
    time_ago_in_words(datetime) + '前' if datetime
  end

  def same_action_name?(action_name)
    'active' if action_name == controller.action_name
  end

  # 言語をシンボルで返す
  def symbolized_lang(path)
    case File.extname(path)
    when '.rb', '.rake'
      :ruby
    when '.cc', '.cp', '.cpp', '.cxx', '.c'
      :c
    when '.py'
      :python
    when '.js', '.coffee'
      :javascript
    when '.java'
      :java
    when '.html'
      :html
    when '.php'
      :php
    when '.sass', '.scss'
      :sass
    when '.css'
      :css
    when '.yml'
      :yaml
    when '.haml'
      :html
    else
      :html
    end
  end

  # シンタックスハイライトで返す
  def coderay(line, path)
    CodeRay.scan(line, symbolized_lang(path)).div.html_safe
  end
end
