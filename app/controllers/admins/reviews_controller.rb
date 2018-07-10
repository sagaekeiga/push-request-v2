class Admins::ReviewsController < ApplicationController
  def index
    @reviews = Review.order(created_at: :desc).page(params[:page])
  end

  def show
  end
end
