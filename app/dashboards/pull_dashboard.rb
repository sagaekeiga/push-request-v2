require "administrate/base_dashboard"

class PullDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    reviewee: Field::BelongsTo,
    reviewer: Field::BelongsTo,
    repo: Field::BelongsTo,
    changed_files: Field::HasMany,
    id: Field::Number,
    remote_id: Field::Number,
    number: Field::Number,
    state: Field::String,
    title: Field::String,
    body: Field::String,
    status: Field::String.with_options(searchable: false),
    token: Field::String,
    deleted_at: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :reviewee,
    :reviewer,
    :repo,
    :changed_files,
    :id,
    :remote_id,
    :number,
    :state,
    :title,
    :body,
    :status,
    :token,
    :deleted_at,
    :created_at,
    :updated_at
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :reviewee,
    :reviewer,
    :repo,
    :changed_files,
    :id,
    :remote_id,
    :number,
    :state,
    :title,
    :body,
    :status,
    :token,
    :deleted_at,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :reviewee,
    :reviewer,
    :repo,
    :changed_files,
    :remote_id,
    :number,
    :state,
    :title,
    :body,
    :status,
    :token,
    :deleted_at,
  ].freeze

  # Overwrite this method to customize how pulls are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(pull)
  #   "Pull ##{pull.id}"
  # end
end
