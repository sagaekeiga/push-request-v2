require "administrate/base_dashboard"

class ReviewerDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    reviews: Field::HasMany,
    review_comments: Field::HasMany,
    skillings: Field::HasMany,
    skills: Field::HasMany,
    pulls: Field::HasMany,
    github_account: Field::HasOne,
    id: Field::Number,
    email: Field::String,
    encrypted_password: Field::String,
    status: Field::String.with_options(searchable: false),
    reset_password_token: Field::String,
    reset_password_sent_at: Field::DateTime,
    remember_created_at: Field::DateTime,
    sign_in_count: Field::Number,
    current_sign_in_at: Field::DateTime,
    last_sign_in_at: Field::DateTime,
    current_sign_in_ip: Field::String.with_options(searchable: false),
    last_sign_in_ip: Field::String.with_options(searchable: false),
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
    :reviews,
    :review_comments,
    :skillings,
    :skills,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :reviews,
    :review_comments,
    :skills,
    :pulls,
    :github_account,
    :id,
    :email,
    :encrypted_password,
    :status,
    :reset_password_token,
    :reset_password_sent_at,
    :remember_created_at,
    :sign_in_count,
    :current_sign_in_at,
    :last_sign_in_at,
    :current_sign_in_ip,
    :last_sign_in_ip,
    :deleted_at,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :reviews,
    :review_comments,
    :skillings,
    :skills,
    :pulls,
    :github_account,
    :email,
    :encrypted_password,
    :status,
    :reset_password_token,
    :reset_password_sent_at,
    :remember_created_at,
    :sign_in_count,
    :current_sign_in_at,
    :last_sign_in_at,
    :current_sign_in_ip,
    :last_sign_in_ip,
    :deleted_at,
  ].freeze

  # Overwrite this method to customize how reviewers are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(reviewer)
  #   "Reviewer ##{reviewer.id}"
  # end
end
