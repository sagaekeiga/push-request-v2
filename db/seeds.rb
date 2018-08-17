languages_yml = File.read('config/languages.yml')
languages = YAML.load(languages_yml)
languages.each do |language|
  Skill.create(
    name: language.flatten[0].to_s,
    category: :language
  )
end
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?