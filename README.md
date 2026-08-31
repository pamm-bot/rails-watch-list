# My Watch List

[![CI](https://github.com/pamm-bot/rails-watch-list/actions/workflows/ci.yml/badge.svg)](https://github.com/pamm-bot/rails-watch-list/actions/workflows/ci.yml)

A movie watch-list app: sign up, create private lists, search real movies via [The Movie Database](https://www.themoviedb.org/) (TMDb), track what's watched vs. still to watch, and leave star ratings and reviews once you've seen something. Any list can be flagged **Under 12**, which filters mature and low-quality titles out of both search and the list itself.

**Live demo:** https://rails-watch-list-pam-ed2b83622ee0.herokuapp.com/

Sign up with any email, or use the ready-made demo account:

| Email | Password |
| --- | --- |
| `demo@watchlist.dev` | `moviebuff` |

![A watch list with its To Watch and Watched sections, movie posters, genre badges, star ratings and reviews](docs/screenshot-list.jpg)

![The home page: a form to create a list, and the colour-coded lists below it](docs/screenshot-home.png)

## Contents

- [Features](#features)
- [Kids mode](#kids-mode)
- [Stack](#stack)
- [Design notes](#design-notes)
- [Setup](#setup)
- [Tests](#tests)
- [Code quality](#code-quality)
- [Possible improvements](#possible-improvements)

## Features

- **Accounts** — sign up and log in; every list is private to the account that created it, with email-based password reset if you forget it
- **Lists** — create as many as you like, each renameable and customisable with an emoji avatar and an accent colour
- **Movie search** — powered by the TMDb API, filterable by category and minimum rating, with or without a title; results refresh as you type
- **Watched / To Watch** — a toggle switch on each movie moves it between the two, updated in place with Turbo Streams (no page reload)
- **Reviews & ratings** — a star-rating review per watched movie, editable or removable at any time
- **Categories** — assigned automatically from each movie's TMDb genre
- **Kids mode** — an optional per-list flag that keeps mature and low-quality titles out (see below)

## Kids mode

TMDb's own `adult` flag misses a lot of borderline content, so a list marked
**Under 12** combines three signals to decide whether a title is allowed:

1. **Blocked genres** — Horror, Crime, Thriller, War
2. **Explicit keywords** in the title (a second line of defence for parody or
   exploitation titles TMDb doesn't flag)
3. **An unusually low vote average** — softcore and low-effort titles rarely get
   flagged but tend to sit well below a real film's rating

The filter applies both to search results and to movies already saved in the
list, so switching a list to Under 12 hides anything that no longer qualifies.
It's deliberately a best-effort filter, not a guarantee — which the code says
too.

## Stack

- Ruby on Rails 8.1, PostgreSQL
- Hotwire (Turbo + Stimulus) with importmap — no JavaScript build step
- Bootstrap 5, simple_form, SCSS
- Rails 8's built-in authentication (bcrypt, signed-cookie sessions)
- solid_cache / solid_queue (database-backed cache and jobs)
- [TMDb API](https://developer.themoviedb.org/reference/intro/getting-started) for movie data, reached through a service object
- RSpec, RuboCop, Brakeman; CI on GitHub Actions
- Deployed on Heroku (Puma, Thrust)

## Design notes

A few decisions worth calling out, and why they went the way they did:

- **Rails 8's built-in auth instead of Devise.** The framework ships a generator
  for it now, so it was a chance to work directly with sessions, signed cookies
  and single-use reset tokens instead of treating them as a black box.
  Authorisation is just scoping: every query starts from `Current.user`, so one
  account can't even address another's records (it gets a 404, not a 403).

- **Turbo Streams instead of a JavaScript front-end.** The only interactive
  moments — moving a movie between Watched and To Watch, deleting a bookmark,
  live search — carry no client-side state. The server renders HTML fragments and
  Turbo swaps them in; a JSON API plus a front-end framework would have been far
  more code for the same behaviour. Stimulus covers the small stuff: debounced
  search, and the live preview of a list's colour and emoji while you pick them.

- **A service object for TMDb.** Every HTTP call and the "is this an adult title?"
  logic live in one class (`TmdbClient`), so controllers stay thin and the rules
  are unit-tested against canned API responses.

- **Movies are shared, bookmarks are per-list.** A `Movie` row is global and
  deduplicated by title; the per-user state (watched, review) hangs off the
  `Bookmark` join between a list and a movie. Two people adding *Inception* reuse
  the same movie record.

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

## Possible improvements

- **System tests** for the Turbo Stream flows — model and controller specs are in
  place, but the front-end behaviour isn't covered end to end
- **Resilience around TMDb** — an explicit request timeout, a retry with backoff,
  and a graceful message when the API is unreachable
- **Search pagination** — results currently stop at TMDb's first page; a "load
  more" control or infinite scroll would help
- **Shared lists** — a read-only link so a list can be shown to someone without
  an account
- **Move off `sassc-rails`** (deprecated) to `dartsass-rails` or Propshaft
- **Watched history** — record when a movie was marked watched, to sort a list by
  "recently watched"
