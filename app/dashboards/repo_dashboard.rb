require "administrate/base_dashboard"

class RepoDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    reviewee: Field::BelongsTo,
    pulls: Field::HasMany,
    skillings: Field::HasMany,
    skills: Field::HasMany,
    id: Field::Number,
    remote_id: Field::Number,
    name: Field::String,
    full_name: Field::String,
    private: Field::Boolean,
    installation_id: Field::Number,
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
    :pulls,
    :skillings,
    :skills,
    :id,
    :remote_id,
    :name,
    :full_name,
    :private,
    :installation_id,
    :deleted_at,
    :created_at,
    :updated_at,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :reviewee,
    :pulls,
    :skillings,
    :skills,
    :id,
    :remote_id,
    :name,
    :full_name,
    :private,
    :installation_id,
    :deleted_at,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :reviewee,
    :pulls,
    :skillings,
    :skills,
    :remote_id,
    :name,
    :full_name,
    :private,
    :installation_id,
    :deleted_at,
  ].freeze

  # Overwrite this method to customize how repos are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(repo)
  #   "Repo ##{repo.id}"
  # end
end
