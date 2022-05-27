# Unprotected Server Example

The unprotected example is the base reference to build the [Approov protected servers](/src/approov-protected-server/). This an Elixir Phoenix Absinthe GraphQL server for a very basic [Todo app](https://github.com/approov/quickstart-flutter-graphql).


## TOC - Table of Contents

* [Why?](#why)
* [How it Works?](#how-it-works)
* [Requirements](#requirements)
* [Try It](#try-it)


## Why?

To be the starting building block for the [Approov protected servers](/src/approov-protected-server), that will show you how to lock down your API server to your mobile app. Please read the brief summary in the [Approov Overview](/OVERVIEW.md#why) at the root of this repo or visit our [website](https://approov.io/product) for more details.

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

You can check by yourself how this is done at `src/unprotected-server/todo/lib/todo/user.ex`, and we hope that this approach gives you enough peace of mind when playing around with the [Todo app](https://github.com/approov/quickstart-flutter-graphql) that may use this server at `https://unprotected.phoenix-absinthe-graphql.demo.approov.io`.


[TOC](#toc---table-of-contents)


## Requirements

To run this example you will need to have Elixir and Phoenix installed. If you don't have then please follow the official installation instructions from [here](https://hexdocs.pm/phoenix/installation.html#content) to download and install them.

Alternatively, you can use the provided docker stack via `src/unprotected-server/todo/docker-compose.yml`, and to use it you need to have [Docker](https://docs.docker.com/install/) and [Docker Compose](https://docs.docker.com/compose/install/) installed in your system.

[TOC](#toc---table-of-contents)


## Try It

All the following shell commands will assume that you have your terminal open at the `src/unprotected-server/todo` folder.

### Create the `.env` File

Create the `.env` from `.env.example`:

```text
cp .env.example .env
```
> **IMPORTANT:** Add the secrets as instructed in the `.env` file comments.

### Run the Server with your Elixir Stack

> **IMPORTANT:** If you already have run the server with the Elixir docker stack we provide via the `docker-compose.yml` file then you need to delete the `_build` and `deps` folders.

First, you need to set the variables from the recently created `.env` file in your environment:

```text
export $(grep -v '^#' .env | xargs -0)
```

Next, you need to install the dependencies with:

```text
mix deps.get
```

Now, you can run this server with an interactive `iex` shell:

```text
iex -S mix phx.server
```

[TOC](#toc---table-of-contents)

### Run the Server with the Provided Elixir Docker Stack

> **IMPORTANT:** If you already have run the server with your local Elixir stack then before you try the docker stack you need to delete the `_build` and `deps` folders.

First, you need to install the dependencies with:

```text
sudo docker-compose run --rm unprotected-dev mix deps.get
```

Now, run the server with an interactive `iex` shell inside the docker container:

```
sudo docker-compose run --rm --service-ports unprotected-dev iex -S mix phx.server
```

Or, run the server without an interactive `iex` shell:

```text
sudo docker-compose up
```

When you finish testing you may want to completely remove the docker stack:

```text
sudo docker-compose down
docker image ls | grep 'approov/quickstart-elixir-phoenix' | awk '{print $3}' | xargs sudo docker image rm
```

[TOC](#toc---table-of-contents)


### Test with the Absinthe GraphiQL Web Interface

#### Create and Authenticate the User

In order to run the tests you need to create an user that matches the `approov` user in the [GraphiQL workspaces](/graphiql).

Run from your `iex` shell:

```bash
Todos.User.create %{"username" => "approov", "password" => "mysuperstrongpass"}
```

Next, you need to authenticate the user in order to enable it to be saved into the last seen `online_users` table in order for you to see the GrapQL subscription working during the tests.

Run from your `iex` shell:

```bash
Todos.User.authenticate %{"username" => "approov", "password" => "mysuperstrongpass"}
```

The token in the output can be dismissed, because the [GraphiQL workspaces](/graphiql) already have valid Authorization tokens for the `approov` user.

#### Ran the Tests

Finally, you can test that it works by using the Absinthe GraphiQL web interface at http://localhost:8002/graphiql.

To make it easier to test you can upload to the web interface this [GraphiQL workspace](/graphiql/graphiql-workspace-unprotected-server.json). After loading the workspace into the GraphiQL web interface you need to refresh the web page and afterwards you can start using the GraphQL queries in the workspace.

First, from the saved queries select the subscription query for `fetchOnlineUsers` and then click in the `play` button, and now you are listening to the last time an user as created a todo, and as mentioned in the message in red `Your subscription data will appear here after server publication!` you need to wait for something to happen, and you cannot close the current web apge or click anywhere on it in order to keep the subscription active.

Next, open a new browser window at http://localhost:8002/graphiql and split your screen in order to have both side to side in order for you to see subscriptions working in realtime.

Now, in the new browser window select the saved mutation query to create a todo and execute it to immediately see the subscription being updated in the other window.


[TOC](#toc---table-of-contents)
