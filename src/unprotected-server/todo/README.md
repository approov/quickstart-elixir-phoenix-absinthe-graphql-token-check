# Unprotected Server Example

The unprotected example is the base reference to build the [Approov protected servers](/src/approov-protected-server/). This an Elixir Phoenix Absinthe GraphQL server for a very basic [Todo app](https://github.com/approov/quickstart-flutter-graphql).


## TOC - Table of Contents

* [Why?](#why)
* [How it Works?](#how-it-works)
* [Requirements](#requirements)
* [Try It](#try-it)


## Why?

To be the starting building block for the [Approov protected servers](/src/approov-protected-server), that will show you how to lock down your API server to your mobile app. Please read the brief summary in the [README](/README.md#why) at the root of this repo or visit our [website](https://approov.io/product.html) for more details.

[TOC](#toc---table-of-contents)


## How it works?

The Elixir Phoenix Absinthe GraphQL server is very simple and is defined in the project located at [src/unprotected-server/todo](/src/unprotected-server/todo).

The server replies to the endpoint `/` for all the [Todo app](https://github.com/approov/quickstart-flutter-graphql) GraphQL queries, and exposes the Absinthe GraphiQL web interface at `/graphiql` in `dev` and `test` environments.


### User Authentication

This server also features a simple user authentication system for the [Todo app](https://github.com/approov/quickstart-flutter-graphql), via Phoenix tokens, that was designed to be completely anonymous, thus users are stored in the database as:

```elixir
iex> Todos.Repo.all! :users
[
  %{
    password_hash: "$2b$12$.8yuoqVi4p1244lboep61evCn1vmQmCgzCU36Fd952JPs9akHOJUG",
    uid: "7ACAE1DE920645200585DDE0D7467107FCC95E21464410399976E28956DBFFF3",
    username: "726C235B9B54334688B36248F45AC845D8B7A3D0F834C54A58DF1C5F45E65FF7"
  },
]
```

You can check by yourself how this is done at `src/unprotected-server/todo/lib/todo/user.ex`, and we hope that this approach gives you enough peace of mind when playing around with the [Todo app](https://github.com/approov/quickstart-flutter-graphql) that may use this server at `https://unprotected.flutter-graphql.demo.approov.io`.


[TOC](#toc---table-of-contents)


## Requirements

To run this example you will need to have Elixir and Phoenix installed. If you don't have then please follow the official installation instructions from [here](https://hexdocs.pm/phoenix/installation.html#content) to download and install them.

Alternatively, you can use the provided docker stack via `src/unprotected-server/todo/docker-compose.yml`, and to use it you need to have [Docker](https://docs.docker.com/install/) and [Docker Compose](https://docs.docker.com/compose/install/) installed in your system.

[TOC](#toc---table-of-contents)


## Try It

### Create the `.env` File

Create the `.env` from one of `.env.production.example` or `.env.localhost.example`:

```text
cp .env.localhost.example .env
```

### Run the Server with your Elixir Stack

First, you need to install the dependencies. From the `src/unprotected-server/todo` folder execute:

```text
mix deps.get
```

Next, you need to set the variables from the recently created `.env` file in your environment:

```text
export $(grep -v '^#' .env | xargs -0)
```

Now, you can run this server from the `src/unprotected-server/todo` folder with an interactive `iex` shell:

```text
iex -S mix phx.server
```

[TOC](#toc---table-of-contents)

### Run the Server with the Provided Elixir Docker Stack

We provide an Elixir Docker stack with all you need to run this server.

First, you need to install the dependencies. From the `src/unprotected-server/todo` folder execute:

```text
sudo docker-compose run unprotected-dev mix deps.get
```

Now, run the server with an interactive `iex` shell inside the docker container:

```
sudo docker-compose run unprotected-dev iex -S mix phx.server
```

Or, run the server without an interactive `iex` shell:

```text
sudo docker-compose up
```

[TOC](#toc---table-of-contents)


### Test with the Absinthe GraphiQL Web Interface

Finally, you can test that it works by using the Absinthe Graphiql web interface at http://localhost:8002/graphiql. To make it easier to test you can upload to the web interface this graphiql workspace: `graphiql/graphiql-workspace-unprotected-server.json`.


[TOC](#toc---table-of-contents)
