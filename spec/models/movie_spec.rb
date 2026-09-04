require 'rails_helper'

RSpec.describe "Movie", type: :model do
  let(:valid_attributes) do
    {
      title: "Titanic",
      overview: "101-year-old Rose DeWitt Bukater tells the story of her life aboard the Titanic, 84 years later.",
      poster_url: "https://image.tmdb.org/t/p/original/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg",
      rating: 7.9
    }
  end

  it "has a title and an overview" do
    movie = Movie.new(title: "Titanic", overview: "101-year-old Rose DeWitt Bukater tells the story of her life aboard the Titanic, 84 years later.")
    expect(movie.title).to eq("Titanic")
    expect(movie.overview).to eq("101-year-old Rose DeWitt Bukater tells the story of her life aboard the Titanic, 84 years later.")
  end

  it "title is unique" do
    Movie.create!(title: "Titanic", overview: "101-year-old Rose DeWitt Bukater tells the story of her life aboard the Titanic, 84 years later.")
    movie = Movie.new(title: "Titanic")
    expect(movie).not_to be_valid
  end

  it "title cannot be blank" do
    attributes = valid_attributes
    attributes.delete(:title)
    movie = Movie.new(attributes)
    expect(movie).not_to be_valid
  end

  it "overview cannot be blank" do
    attributes = valid_attributes
    attributes.delete(:overview)
    movie = Movie.new(attributes)
    expect(movie).not_to be_valid
  end

  it "has many bookmarks" do
    movie = Movie.new(valid_attributes)
    expect(movie).to respond_to(:bookmarks)
    expect(movie.bookmarks.count).to eq(0)
  end

  it "should not be able to destroy self if has bookmarks children" do
    movie = Movie.create!(valid_attributes)
    user = User.create!(email_address: "movie_spec@example.com", password: "password123")
    list = List.create!(name: "Drama", user: user)
    movie.bookmarks.create(list: list, comment: "Great movie!")

    expect { movie.destroy }.to raise_error(ActiveRecord::InvalidForeignKey)
  end

  describe ".upsert_from_tmdb" do
    let(:payload) do
      { title: "Dune", overview: "Paul Atreides.", poster_path: "/dune.jpg", vote_average: "8.1", genre_id: "878" }
    end

    it "creates a movie, rounding the rating and assigning the genre category" do
      movie = Movie.upsert_from_tmdb(**payload)

      expect(movie).to be_persisted
      expect(movie.rating).to eq(8)
      expect(movie.category.name).to eq("Science Fiction")
    end

    it "reuses an existing movie with the same title" do
      Movie.create!(title: "Dune", overview: "Old copy.")

      expect { Movie.upsert_from_tmdb(**payload) }.not_to change(Movie, :count)
    end

    it "falls back to the no-overview string when the payload has none" do
      movie = Movie.upsert_from_tmdb(**payload, overview: "")

      expect(movie.overview).to eq(I18n.t("movies.no_overview"))
    end
  end
end
