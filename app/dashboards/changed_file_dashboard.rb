require "administrate/base_dashboard"

class ChangedFileDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    pull: Field::BelongsTo,
    review_comments: Field::HasMany,
    id: Field::Number,
    sha: Field::String,
    filename: Field::String,
    status: Field::String,
    additions: Field::Number,
    deletions: Field::Number,
    difference: Field::Number,
    blob_url: Field::String,
    raw_url: Field::String,
    contents_url: Field::String,
    patch: Field::Text,
    commit_id: Field::String,
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
    :pull,
    :review_comments,
    :id,
    :sha,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :pull,
    :review_comments,
    :id,
    :sha,
    :filename,
    :status,
    :additions,
    :deletions,
    :difference,
    :blob_url,
    :raw_url,
    :contents_url,
    :patch,
    :commit_id,
    :deleted_at,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :pull,
    :review_comments,
    :sha,
    :filename,
    :status,
    :additions,
    :deletions,
    :difference,
    :blob_url,
    :raw_url,
    :contents_url,
    :patch,
    :commit_id,
    :deleted_at,
  ].freeze

  # Overwrite this method to customize how changed files are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(changed_file)
  #   "ChangedFile ##{changed_file.id}"
  # end
end
