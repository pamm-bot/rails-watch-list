class Bookmark < ApplicationRecord
  belongs_to :list
  belongs_to :movie

  validates :movie, presence: true
  validates :list, presence: true
  validates :movie_id, uniqueness: { scope: :list_id }
  validates :comment, length: { minimum: 6 }
end
