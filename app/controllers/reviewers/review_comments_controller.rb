require 'action_view'
require 'action_view/helpers'
include ActionView::Helpers::DateHelper
class Reviewers::ReviewCommentsController < ApplicationController
  protect_from_forgery except: %i(create update)
  before_action :set_changed_file, only: %i(create)
  before_action :set_pull, only: %i(create)
  before_action :set_review_comment, only: %i(destroy update show)

  def create
    reviewer = Reviewer.find(params[:reviewer_id])
    @changed_file = ChangedFile.find(params[:changed_file_id])

    return render json: { status: 'failed' } if @changed_file.nil? || reviewer.nil?

    review_comment = @changed_file.review_comments.new(
      position: params[:position],
      path: params[:path]&.gsub('\n', ''),
      body: params[:body],
      reviewer: reviewer,
      in_reply_to_id: params[:reply].present? ? @changed_file.review_comments.last.remote_id : nil
    )

    review_comment.status = :commented if params[:status]

    if review_comment.save
      # @TODO review_commentにもcommit_idカラム追加
      review_comment.send_github!(params[:commit_id]) if params[:commit_id]
      Rails.application.config.another_logger.info 'review_comments#create'
      Rails.application.config.another_logger.info review_comment.id
      Rails.application.config.another_logger.info params[:body]
      Rails.application.config.another_logger.info reviewer.github_account.avatar_url
      Rails.application.config.another_logger.info reviewer.github_account.nickname
      Rails.application.config.another_logger.info time_ago_in_words(review_comment.updated_at) + '前'
      Rails.application.config.another_logger.info review_comment.remote_id
      Rails.application.config.another_logger.info 'review_comments#create'
      render json: {
        status: 'success',
        review_comment_id: review_comment.id,
        body: params[:body],
        img: reviewer.github_account.avatar_url,
        name: reviewer.github_account.nickname,
        time: time_ago_in_words(review_comment.updated_at) + '前',
        remote_id: review_comment.remote_id
      }
    else
      render json: { status: 'failed' }
    end
  end

  def update
    if @review_comment.update(body: params[:body])
      render json: {
        status: 'success',
        body: params[:body]
      }
    else
      render json: { status: 'failed' }
    end
  end

  def destroy
    if @review_comment.destroy
      render json: { status: 'success' }
    else
      render json: { status: 'failed' }
    end
  end

  def show
    respond_to do |format|
      format.json do
        render json: {
          body: @review_comment.body
        }
      end
    end
  end

  private

  def set_changed_file
    @changed_file = ChangedFile.find(params[:changed_file_id])
  end

  def set_pull
    @pull = @changed_file.pull
  end

  def set_review_comment
    @review_comment = ReviewComment.find(params[:id])
  end
end
