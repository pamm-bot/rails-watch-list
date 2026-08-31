# Categories mirror TMDb's fixed genre list.
TmdbClient::GENRES.values.each { |name| Category.find_or_create_by!(name: name) }

# ---------------------------------------------------------------------------
# Demo account
#
# A ready-made login for anyone browsing the portfolio, pre-filled with a
# handful of lists so the app isn't an empty shell on first visit. Movie
# data is pulled live from TMDb so the posters and ratings are real.
#
# Re-running `bin/rails db:seed` rebuilds this one account from scratch and
# leaves every other user untouched.
# ---------------------------------------------------------------------------
DEMO_EMAIL = "demo@watchlist.dev".freeze
DEMO_PASSWORD = "moviebuff".freeze

demo = User.find_or_initialize_by(email_address: DEMO_EMAIL)
demo.password = DEMO_PASSWORD
demo.save!
demo.lists.destroy_all

unless TmdbClient.api_key.present?
  puts "No TMDb API key configured — created the demo account but skipping its movies."
  return
end

lists = [
  {
    name: "Weekend Picks", emoji: "🍿", color: "#f77f00",
    movies: [
      { title: "Everything Everywhere All at Once", watched: true,
        review: { rating: 5, content: "Chaotic, funny and unexpectedly moving. Worth the hype." } },
      { title: "Knives Out", watched: true,
        review: { rating: 4, content: "A proper whodunit with a cast that's clearly having fun." } },
      { title: "Mad Max: Fury Road" },
      { title: "Parasite" },
      { title: "Dune" }
    ]
  },
  {
    name: "Sci-Fi Marathon", emoji: "🚀", color: "#0066ff",
    movies: [
      { title: "Blade Runner 2049", watched: true,
        review: { rating: 5, content: "Slow, gorgeous, and every frame looks like a painting." } },
      { title: "Arrival", watched: true,
        review: { rating: 4, content: "A first-contact film that's really about language and grief." } },
      { title: "Interstellar" },
      { title: "The Matrix" },
      { title: "Ex Machina" }
    ]
  },
  {
    name: "Comfort Watches", emoji: "🌟", color: "#06d6a0",
    movies: [
      { title: "Spirited Away", watched: true,
        review: { rating: 5, content: "The one I put on when I need cheering up." } },
      { title: "Paddington 2", watched: true,
        review: { rating: 5, content: "Genuinely one of the kindest films ever made." } },
      { title: "The Grand Budapest Hotel" },
      { title: "Chef" },
      { title: "Ratatouille" }
    ]
  }
]

import_movie = lambda do |title|
  result = TmdbClient.search(title).find { |r| r["poster_path"].present? }
  return nil if result.nil?

  movie = Movie.find_or_initialize_by(title: result["title"])
  movie.overview = result["overview"].presence || "No overview available."
  movie.poster_url = TmdbClient.poster_url(result["poster_path"])
  movie.rating = result["vote_average"].to_f.round
  if (genre_name = TmdbClient.genre_name(result["genre_ids"]&.first))
    movie.category = Category.find_or_create_by!(name: genre_name)
  end
  movie.save!
  movie
rescue StandardError => e
  puts "  ! Could not import #{title.inspect}: #{e.message}"
  nil
end

lists.each do |attrs|
  list = demo.lists.create!(attrs.slice(:name, :emoji, :color))

  attrs[:movies].each do |entry|
    movie = import_movie.call(entry[:title])
    next if movie.nil?

    bookmark = Bookmark.create!(list: list, movie: movie, watched: entry.fetch(:watched, false))
    bookmark.reviews.create!(entry[:review]) if entry[:review]
  end

  puts "  ✓ #{list.name} (#{list.bookmarks.count} movies)"
end

puts "Demo account ready: #{DEMO_EMAIL} / #{DEMO_PASSWORD}"
