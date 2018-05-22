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
end
