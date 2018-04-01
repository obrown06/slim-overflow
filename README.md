# slim-overflow

**slim-overflow** is a web application which implements much (but not all) of the core
functionality of [Stack Overflow](https://stackoverflow.com/). It is written in [Elixir](https://github.com/elixir-lang/elixir) and built on the [Phoenix Framework](https://github.com/phoenixframework/phoenix).

Some of the features it supports:

  * User accounts (including auth, OAuth, email verification, etc.)
  * CRUD operations for questions, responses, nested comments, categories
  * User reputation as determined by upvotes, downvotes, response "promotions"
  * View metrics for profiles, questions, categories
  * Live chatrooms associated with each question, built using Phoenix Channels

## Setup

1. Install Elixir [here](https://elixir-lang.org/install.html) and Phoenix, Node.js, and PostgreSQL  [here](https://hexdocs.pm/phoenix/installation.html).

2. Install dependencies with `mix deps.get`.
3. Create and migrate the Postgres database with `mix ecto.create && mix ecto.migrate`.
4. Install Node.js dependencies with `cd assets && npm install`
5. Start Phoenix endpoint with `mix phx.server`

Now visit [`localhost:4000`](http://localhost:4000) and have at it!
