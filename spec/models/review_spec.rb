require 'rails_helper'

RSpec.describe "Review", type: :model do
  let(:user) do
    User.create!(email_address: "review_spec@example.com", password: "password123")
  end

  let(:movie) do
    Movie.create!(title: "Titanic", overview: "A ship sinks.")
  end

  let(:bookmark) do
    list = List.create!(name: "Drama", user: user)
    Bookmark.create!(list: list, movie: movie)
  end

  let(:valid_attributes) do
    { content: "Loved it!", rating: 5, bookmark: bookmark }
  end

  it "is valid with content, a rating, and a bookmark" do
    review = Review.new(valid_attributes)
    expect(review).to be_valid
  end

  it "is valid with only a rating" do
    review = Review.new(valid_attributes.merge(content: nil))
    expect(review).to be_valid
  end

  it "is valid with only written content" do
    review = Review.new(valid_attributes.merge(rating: nil))
    expect(review).to be_valid
  end

  it "is invalid with neither a rating nor content" do
    review = Review.new(valid_attributes.merge(content: " ", rating: nil))
    expect(review).not_to be_valid
  end

  it "requires a rating between 0 and 5" do
    review = Review.new(valid_attributes.merge(rating: 6))
    expect(review).not_to be_valid
  end

  it "accepts a rating of 0" do
    review = Review.new(valid_attributes.merge(rating: 0))
    expect(review).to be_valid
  end

  it "allows only one review per bookmark" do
    Review.create!(valid_attributes)
    review = Review.new(valid_attributes)
    expect(review).not_to be_valid
  end
end
