require "administrate/base_dashboard"

class ReviewCommentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    review: Field::BelongsTo,
    changed_file: Field::BelongsTo,
    reviewer: Field::BelongsTo,
    id: Field::Number,
    body: Field::Text,
    path: Field::String,
    position: Field::Number,
    github_id: Field::Number,
    in_reply_to_id: Field::Number,
    status: Field::String.with_options(searchable: false),
    github_created_at: Field::DateTime,
    github_updated_at: Field::DateTime,
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
    :review,
    :changed_file,
    :reviewer,
    :id,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :review,
    :changed_file,
    :reviewer,
    :id,
    :body,
    :path,
    :position,
    :github_id,
    :in_reply_to_id,
    :status,
    :github_created_at,
    :github_updated_at,
    :deleted_at,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :review,
    :changed_file,
    :reviewer,
    :body,
    :path,
    :position,
    :github_id,
    :in_reply_to_id,
    :status,
    :github_created_at,
    :github_updated_at,
    :deleted_at,
  ].freeze

  # Overwrite this method to customize how review comments are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(review_comment)
  #   "ReviewComment ##{review_comment.id}"
  # end
end
