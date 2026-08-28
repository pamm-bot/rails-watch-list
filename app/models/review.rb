class Review < ApplicationRecord
  belongs_to :bookmark

  validates :content, presence: true
  validates :rating, inclusion: { in: 0..5 }
  validates :bookmark_id, uniqueness: true
end
