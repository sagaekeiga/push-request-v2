require "administrate/base_dashboard"

class ReviewDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    reviewer: Field::BelongsTo,
    pull: Field::BelongsTo,
    review_comments: Field::HasMany,
    id: Field::Number,
    body: Field::Text,
    state: Field::String,
    event: Field::String.with_options(searchable: false),
    working_hours: Field::Number,
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
    :reviewer,
    :pull,
    :review_comments,
    :id,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :reviewer,
    :pull,
    :review_comments,
    :id,
    :body,
    :state,
    :event,
    :working_hours,
    :deleted_at,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :reviewer,
    :pull,
    :review_comments,
    :body,
    :state,
    :event,
    :working_hours,
    :deleted_at,
  ].freeze

  # Overwrite this method to customize how reviews are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(review)
  #   "Review ##{review.id}"
  # end
end
