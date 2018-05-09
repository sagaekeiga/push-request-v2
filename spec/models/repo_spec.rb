# == Schema Information
#
# Table name: repos
#
#  id         :bigint(8)        not null, primary key
#  deleted_at :datetime
#  full_name  :string
#  name       :string
#  private    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  remote_id  :integer
#  user_id    :bigint(8)
#
# Indexes
#
#  index_repos_on_deleted_at  (deleted_at)
#  index_repos_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe Repo, type: :model do
  let(:repo_new) { user.repos }
  let(:repo) { create(:repo, user: user) }
  let(:user) { create(:user) }
  let(:repositories_added_params) {
    [
      [
        ActionController::Parameters.new(
          id: id,
          name: name,
          full_name: full_name,
          private: true
        ).permit(:question_section_id, :body)
      ]
    ]
  }
  # リモートのレポジトリを保存する
  describe '#create_or_restore!' do
    # context 'レポジトリが空なら作成する' do
    #   let(:id) { repo.remote_id + 1 }
    #   let(:name) { repo.name + 'n' }
    #   let(:full_name) { repo.full_name + 'n' }
    #   subject {
    #     repo_new.create_or_restore!(repositories_added_params)
    #     Repo.count
    #   }
    #   it { is_expected.to eq 1 }
    # end

    # context 'レポジトリがすでに存在すれば作成しない' do
    #   let(:started_at) { Time.zone.today }
    #   let(:reminded_at) { Time.zone.today }
    #   let(:ended_at) { Time.zone.today }
    #   it { is_expected.to 2 }
    # end
    #
    # context '論理削除されたレポジトリが存在すればリストアする' do
    #   let(:started_at) { Time.zone.today }
    #   let(:reminded_at) { Time.zone.today }
    #   let(:ended_at) { Time.zone.today }
    #   it { expect(survey).not_to be_valid }
    # end
  end
end
