module BookmarksHelper
  # A distinct accent color per TMDb genre, so a movie's category is
  # recognizable at a glance on its poster instead of just plain text.
  GENRE_COLORS = {
    "Action" => "#e63946",
    "Adventure" => "#f77f00",
    "Animation" => "#06d6a0",
    "Comedy" => "#f4a300",
    "Crime" => "#4a4e69",
    "Documentary" => "#6c757d",
    "Drama" => "#9d4edd",
    "Family" => "#2ec4b6",
    "Fantasy" => "#7209b7",
    "History" => "#a68a64",
    "Horror" => "#1d1d1d",
    "Music" => "#ff6392",
    "Mystery" => "#495057",
    "Romance" => "#ff5d8f",
    "Science Fiction" => "#118ab2",
    "TV Movie" => "#adb5bd",
    "Thriller" => "#d90429",
    "War" => "#6a4c93",
    "Western" => "#bc6c25"
  }.freeze

  def genre_badge_color(genre_name)
    GENRE_COLORS[genre_name] || "#7209b7"
  end
end
