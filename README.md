# Rails Watch List

A movie watch-list app: create lists, search real movies via [The Movie Database](https://www.themoviedb.org/) (TMDb), track what's watched vs. still to watch, and leave star ratings and reviews once you've seen something.

**Live demo:** https://rails-watch-list-pam-ed2b83622ee0.herokuapp.com/

## Features

- **Lists** — create as many as you like, each with its own movies
- **Movie search** — powered by the TMDb API, filterable by category and minimum rating, with or without a title
- **Watched / To Watch** — a toggle switch on each movie moves it between the two, updated in place with Turbo Streams (no page reload)
- **Reviews & ratings** — a star-rating review per watched movie
- **Categories** — assigned automatically from each movie's TMDb genre
- **Kids mode** — an optional per-list flag that filters out Horror and explicit content from search results and the list itself

## Stack

- Ruby on Rails 8.1, PostgreSQL
- Hotwire (Turbo + Stimulus), Bootstrap 5, simple_form
- [TMDb API](https://developer.themoviedb.org/reference/intro/getting-started) for movie data
- RSpec for tests

## Setup

```bash
bundle install
bin/rails db:setup
```

You'll need a free TMDb API key (v3 auth), added to Rails credentials:

```bash
EDITOR="code --wait" bin/rails credentials:edit
```

```yaml
tmdb:
  api_key: your_key_here
```

Then start the app:

```bash
bin/rails server
```

## Tests

```bash
bundle exec rspec
```
