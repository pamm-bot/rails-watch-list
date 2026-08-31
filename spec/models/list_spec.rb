require 'rails_helper'

RSpec.describe "List", type: :model do
  let(:user) do
    User.create!(email_address: "list_spec@example.com", password: "password123")
  end

  let(:valid_attributes) do
    {
      name: "Comedy",
      user: user
    }
  end

  let(:titanic) do
    Movie.create!(title: "Titanic", overview: "101-year-old Rose DeWitt Bukater tells the story of her life aboard the Titanic, 84 years later.")
  end

  it "has a name" do
    list = List.new(name: "Comedy", user: user)
    expect(list.name).to eq("Comedy")
  end

  it "name cannot be blank" do
    list = List.new(user: user)
    expect(list).not_to be_valid
  end

  it "name is unique" do
    List.create!(name: "Comedy", user: user)
    list = List.new(name: "Comedy", user: user)
    expect(list).not_to be_valid
  end

  it "accepts a color from the app's accent palette" do
    list = List.new(name: "Comedy", user: user, color: List::ACCENT_COLORS.first)
    expect(list).to be_valid
  end

  it "rejects a color outside the accent palette" do
    list = List.new(name: "Comedy", user: user, color: "#123456")
    expect(list).not_to be_valid
  end

  it "allows a blank color" do
    list = List.new(name: "Comedy", user: user, color: nil)
    expect(list).to be_valid
  end

  it "rejects an overly long emoji field" do
    list = List.new(name: "Comedy", user: user, emoji: "a" * 9)
    expect(list).not_to be_valid
  end

  it "has many bookmarks" do
    list = List.new(valid_attributes)
    expect(list).to respond_to(:bookmarks)
    expect(list.bookmarks.count).to eq(0)
  end

  it "has many movies" do
    list = List.create!(valid_attributes)
    expect(list).to respond_to(:movies)
    expect(list.movies.count).to eq(0)

    list.bookmarks.create(list: list, movie: titanic, comment: "Great movie!")
    expect(list.movies.count).to eq(1)
  end

  it "should destroy child bookmarks when destroying self (in other words, should remove movies from the list when it is deleted)" do
    list = List.create!(valid_attributes)
    list.bookmarks.create(list: list, movie: titanic, comment: "Great movie!")
    expect { list.destroy }.to change { Bookmark.count }.from(1).to(0)
  end

  describe "kids mode" do
    let(:horror_category) { Category.create!(name: "Horror") }
    let(:kids_list) { List.create!(name: "Kids", user: user, kids_mode: true) }

    # bookmarks_by_watched only surfaces movies with a poster, so these need one.
    let(:posterable_titanic) do
      Movie.create!(title: "Titanic", overview: "A ship sinks.", poster_url: "https://example.com/titanic.jpg")
    end

    def bookmark_for(list, movie)
      list.bookmarks.create!(movie: movie, comment: "Some comment")
    end

    it "allows any movie when kids mode is off" do
      list = List.create!(valid_attributes)
      scary_movie = Movie.create!(title: "Scary Movie", overview: "Spooky.", category: horror_category)
      expect(list.movie_allowed?(scary_movie)).to eq(true)
    end

    it "rejects movies in a mature genre" do
      scary_movie = Movie.create!(title: "Scary Movie", overview: "Spooky.", category: horror_category)
      expect(kids_list.movie_allowed?(scary_movie)).to eq(false)
    end

    it "rejects movies with an explicit title" do
      explicit_movie = Movie.create!(title: "XXX Movie", overview: "Not for kids.")
      expect(kids_list.movie_allowed?(explicit_movie)).to eq(false)
    end

    it "rejects movies with a low rating" do
      low_rated_movie = Movie.create!(title: "Bad Movie", overview: "Not great.", rating: 2)
      expect(kids_list.movie_allowed?(low_rated_movie)).to eq(false)
    end

    it "allows an ordinary movie" do
      expect(kids_list.movie_allowed?(posterable_titanic)).to eq(true)
    end

    it "filters out disallowed movies from bookmarks_by_watched" do
      scary_movie = Movie.create!(title: "Scary Movie", overview: "Spooky.", category: horror_category, poster_url: "https://example.com/scary.jpg")
      bookmark_for(kids_list, posterable_titanic)
      bookmark_for(kids_list, scary_movie)

      to_watch, watched = kids_list.bookmarks_by_watched
      expect((to_watch + watched).map(&:movie)).to eq([ posterable_titanic ])
    end

    it "still partitions watched vs. to-watch movies when kids mode is on" do
      bookmark = bookmark_for(kids_list, posterable_titanic)
      bookmark.update!(watched: true)

      to_watch, watched = kids_list.bookmarks_by_watched
      expect(to_watch).to be_empty
      expect(watched.map(&:movie)).to eq([ posterable_titanic ])
    end
  end
end
