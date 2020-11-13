# Docker Stack for Production Releases

The docker stack to build and run the docker image with a production release for each API backend example in this Approov quickstart.

If you are looking how to run each API backend example in your laptop, while poking around with the code, then you should look at the README of each one.


## How to Deploy to Production

Clone the repo:

```text
git clone https://github.com/approov/quickstart-elixir-phoenix-absinthe-graphql-token-check.git
```

Move to inside the docker stack production folder:

```text
cd quickstart-elixir-phoenix-absinthe-graphql-token-check/docker/production
```

Create the `.env` file:

```text
cp .env.example .env
```
> **IMPORTANT:** Add the secrets as instructed in the `.env` file comments.

Run all services in the background:

```text
sudo docker-compose up --detach
```
> **NOTE:** The first time you run the command it will build the docker images.

At any time check the logs with:

```text
sudo docker-compose logs --follow --tail 100
```

If you update the `.env` file then you need to bring down the docker stack and bring it up again, a restart will not reload the `.env` file.

```text
sudo docker-compose down && sudo docker-compose up --detach
```

## How to Inspect a Running Elixir Production Release

First, get inside the running container for a specific docker compose service:

```text
sudo docker-compose exec approov-token zsh
```

Next, get an interactive `iex` shell for the running elixir node:

```text
./bin/todo remote
```

And you should see something similar to:

```text
Erlang/OTP 23 [erts-11.1.2] [source] [64-bit] [smp:2:2] [ds:2:2:10] [async-threads:1] [hipe]

Interactive Elixir (1.11.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(todo@8a9c06554464)1>
```

Now, you can check all registered users:

```text
iex> Todos.Repo.all! :users
[
  %{
    password_hash: "$2b$12$bXv1hkTvWohp12zX0j/JtuClnUtmpjvGH.hAauNg53oMVPtS1ySJC",
    uid: "60B4E74E753A875BE09ABD5D39729437AF453F6BA38306F645FCADC7CEACF895",
    username: "EC238B479F2CEF4E2F7770E8DD5F574A29EC1B54FAF61219E879F5849D766943"
  }
]
```

Or, you can get all todos:

```text
iex> Todos.Repo.all! :todos
[
  %{
    created_at: "2020-11-12 19:43:40.664589",
    id: 403,
    is_completed: false,
    is_public: false,
    title: "task 2",
    uid: "05B0ED0083F1B5B61071A2C68DC1520D8E1C4E5F22D549D371AA25CA151B1C60",
    user_uid: "60B4E74E753A875BE09ABD5D39729437AF453F6BA38306F645FCADC7CEACF895"
  }
]
```

Or, just get the todos for a specific user:

```text
iex> Todos.Context.all_todos %{current_user: %{uid: "60B4E74E753A875BE09ABD5D39729437AF453F6BA38306F645FCADC7CEACF895"}}
{:ok,
 [
   %{
     created_at: "2020-11-12 19:43:40.664589",
     id: 403,
     is_completed: false,
     is_public: false,
     title: "task 2",
     uid: "05B0ED0083F1B5B61071A2C68DC1520D8E1C4E5F22D549D371AA25CA151B1C60",
     user_uid: "60B4E74E753A875BE09ABD5D39729437AF453F6BA38306F645FCADC7CEACF895"
   }
 ]}
```
