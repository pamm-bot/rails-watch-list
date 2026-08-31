# My Watch List

[![CI](https://github.com/pamm-bot/rails-watch-list/actions/workflows/ci.yml/badge.svg)](https://github.com/pamm-bot/rails-watch-list/actions/workflows/ci.yml)

A movie watch-list app: sign up, create private lists, search real movies via [The Movie Database](https://www.themoviedb.org/) (TMDb), track what's watched vs. still to watch, and leave star ratings and reviews once you've seen something.

**Live demo:** https://rails-watch-list-pam-ed2b83622ee0.herokuapp.com/

Sign up with any email, or use the ready-made demo account:

| Email | Password |
| --- | --- |
| `demo@watchlist.dev` | `moviebuff` |

![A watch list with its To Watch and Watched sections, movie posters, genre badges, star ratings and reviews](docs/screenshot-list.jpg)

![The home page: a form to create a list, and the colour-coded lists below it](docs/screenshot-home.png)

## Features

- **Accounts** — sign up and log in; every list is private to the account that created it, with email-based password reset if you forget it
- **Lists** — create as many as you like, each with its own movies, renameable at any time
- **Movie search** — powered by the TMDb API, filterable by category and minimum rating, with or without a title
- **Watched / To Watch** — a toggle switch on each movie moves it between the two, updated in place with Turbo Streams (no page reload)
- **Reviews & ratings** — a star-rating review per watched movie, editable or removable at any time
- **Categories** — assigned automatically from each movie's TMDb genre
- **Kids mode** — an optional per-list flag that filters out Horror, Crime, Thriller, War, and other mature or low-quality content from search results and the list itself

## Stack

- Ruby on Rails 8.1, PostgreSQL
- Hotwire (Turbo + Stimulus), Bootstrap 5, simple_form
- Rails 8's built-in authentication (bcrypt, session-based)
- [TMDb API](https://developer.themoviedb.org/reference/intro/getting-started) for movie data
- RSpec for tests
- Deployed on Heroku

## Setup

```bash
bundle install
bin/rails db:setup   # create, load schema, and seed the demo account
```

`db:seed` builds the `demo@watchlist.dev` account with three sample lists,
pulling the movies live from TMDb (it's skipped cleanly if no API key is
set yet). Re-running it rebuilds that account and leaves other users alone.

You'll need a free TMDb API key (v3 auth), added to Rails credentials:

```bash
EDITOR="code --wait" bin/rails credentials:edit
```

```yaml
tmdb:
  api_key: your_key_here
```

Password reset emails need a Gmail account with an [App Password](https://myaccount.google.com/apppasswords) (optional locally — without it, reset requests just don't send, no crash):

```yaml
gmail:
  user_name: you@gmail.com
  app_password: your_app_password
```

Then start the app:

```bash
bin/rails server
```

## Tests

```bash
bundle exec rspec
```

Runs automatically on every push and pull request via GitHub Actions. The
suite covers models, controllers, and the TMDb client, including auth,
kids mode, and the watched/review flows.

## Code quality

```bash
bundle exec rubocop    # style, following Rails' omakase config
bundle exec brakeman   # static security analysis
```
