# == Schema Information
#
# Table name: skills
#
#  id         :bigint(8)        not null, primary key
#  category   :integer
#  deleted_at :datetime
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_skills_on_deleted_at  (deleted_at)
#

class Skill < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  has_many :skillings, dependent: :destroy
  has_many :reviewers

  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # カテゴリ
  #
  # - language        : プログラミング言語
  #
  enum category: {
    language:  1000
  }

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :name, presence: true, uniqueness: true

  def self.top_match_by(alphabet)
    language.where("name like '#{alphabet}%'").or(language.where("name like '#{alphabet.upcase}%'"))
  end

  def self.fetch!(skill_name, repo)
    skill = with_deleted.find_by(name: skill_name)
    skilling = skill.skillings.find_or_initialize_by(
      resource_type: 'Repo',
      resource_id:   repo.id
    )
    skilling.save! if skilling.new_record?
    skilling.restore if skilling.deleted?
  end
end
