class ChangedFileDecorator < ApplicationDecorator
  delegate_all
  # 言語をシンボルで返す
  def symbolized_lang
    case File.extname(ChangedFile.last.filename)
    when '.rb'
      :ruby
    when '.cc', '.cp', '.cpp', '.cxx', '.c'
      :c
    when '.py'
      :python
    when '.js'
      :javascript
    when '.java'
      :java
    when '.html'
      :html
    when '.php'
      :php
    when '.sass', 'scss'
      :sass
    when '.css'
      :css
    when '.yml'
      :yaml
    end
  end

  # シンタックスハイライトで返す
  def coderay(line)
    CodeRay.scan(line, object.decorate.symbolized_lang).div.html_safe
  end

  # レビューコメントがあるかどうかを返す
  def present_review_comment?(index)
    review_comments.find_by(position: index).present?
  end

  # レビューコメントのIDを返す
  def review_comment_id(index)
    review_comments.find_by(position: index)&.id
  end

  # レビューコメントを返す
  def review_comment_body(index)
    review_comments.find_by(position: index)&.body
  end

  # レビューコメントのパスを返す
  def review_comment_path(index)
    review_comments.find_by(position: index)&.path
  end

  # レビューコメントのポジションを返す
  def review_comment_position(index)
    review_comments.find_by(position: index)&.position
  end
end
