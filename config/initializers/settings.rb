Settings.reload_from_files(
  Rails.root.join('config', 'settings.yml').to_s,
  Rails.root.join('config', 'settings', 'api.yml').to_s,
  # Rails.root.join('config', 'settings', 'enums.yml').to_s,
  Rails.root.join('config', 'settings', 'meta.yml').to_s,
  Rails.root.join('config', 'settings', 'constraints.yml').to_s,
  Rails.root.join('config', 'settings', "#{Rails.env}.yml").to_s
)
