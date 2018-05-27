namespace :pulls do
  task all: %i[auto_cancel]
  task auto_cancel: :environment do
    expired_pulls = Pull.agreed.where("updated_at <= ?", Time.zone.now - 2.hours)
    expired_pulls.each(&:canceled!)
  end
end
