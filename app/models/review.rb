class Review < ApplicationRecord
  belongs_to :bookmark

  # A rating and the written review are independent: either one on its
  # own is a valid review, but an empty one is not.
  validates :rating, inclusion: { in: 0..5 }, allow_nil: true
  validates :bookmark_id, uniqueness: true
  validate :rating_or_content_present

  private

  def rating_or_content_present
    return if rating.present? || content.present?

    errors.add(:base, "Add a rating or write something")
  end
end
