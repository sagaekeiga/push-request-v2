Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?

  provider :github,
   ENV['GITHUB_CLIENT_ID'],
   ENV['GITHUB_CLIENT_SECRET'],
   scope: 'read:org'

  on_failure do |env|
    # we need to setup env
    if env['omniauth.params'].present?
      env["devise.mapping"] = Devise.mappings[:reviewee]
    end

    ConnectsController.action(:failure).call(env)
  end

  configure do |config|
  config.path_prefix = '/auth'
  config.full_host = "https://" + ENV['WEB_DOMAIN'] if Rails.env.production?
  end
end
