# Approov QuickStart - Elixir Phoenix Absinthe GraphQL Token Check

[Approov](https://approov.io) is an API security solution used to verify that requests received by your backend services originate from trusted versions of your mobile apps.

This repo implements the Approov server-side request verification code in [Elixir](https://elixir-lang.org/), which performs the verification check before allowing valid traffic to be processed by the GraphQL API endpoint.

This is an Approov integration quickstart example for the Elixir Phoenix framework. If you are looking for another Elixir integration you can check our list of [quickstarts](https://approov.io/docs/latest/approov-integration-examples/backend-api/), and if you don't find what you are looking for, then please let us know [here](https://approov.io/contact).


## Approov Integration Quickstart

The quickstart was tested with the following Operating Systems:

* Ubuntu 20.04
* MacOS Big Sur
* Windows 10 WSL2 - Ubuntu 20.04

First, setup the [Approov CLI](https://approov.io/docs/latest/approov-installation/index.html#initializing-the-approov-cli).

Now, register the API domain for which Approov will issues tokens:

```bash
approov api -add api.example.com
```

Next, enable your Approov `admin` role with:

```bash
eval `approov role admin`
````

For the Windows powershell:

```bash
set APPROOV_ROLE=admin:___YOUR_APPROOV_ACCOUNT_NAME_HERE___
```

Now, retrieve the [Approov secret](https://approov.io/docs/latest/approov-usage-documentation/#account-secret-key-export):

```bash
approov secret -get base64Url
```

Next, export the Approov secret into the environment:

```env
export APPROOV_BASE64URL_SECRET=approov_base64url_secret_here
```

Now, fetch the Approov secret in the `config/runtime.exs` file:

```elixir
approov_secret =
  System.get_env("APPROOV_BASE64URL_SECRET") ||
    raise "Environment variable APPROOV_BASE64URL_SECRET is missing."

config :YOUR_APP, ApproovToken,
  secret_key: approov_secret |> Base.url_decode64!(padding: false)
```

Next, add the [JWT dependency](https://github.com/joken-elixir/joken) to your `mix.exs` file:

```elixir
{:joken, "~> 2.4"},
# Recommended JSON library
{:jason, "~> 1.2"}
```

Now, fetch the new dependency:

```bash
mix deps.get
```

Next, add the `ApproovToken` Module to your project:

```elixir
defmodule ApproovToken do
  require Logger

  use Joken.Config

  @impl Joken.Config
  def token_config, do: default_claims(skip: [:aud, :iat, :iss, :jti, :nbf])

  # Verifies the token from an HTTP request or from a Websockets connection/event
  def verify_token(params) do
    with {:ok, approov_token} <- _get_approov_token(params),
         {:ok, approov_token_claims} <- _decode_and_verify(approov_token) do

      {:ok, approov_token_claims}
    else
      {:error, reason} ->
        Logger.info(%{approov_token_error: reason})
        {:error, reason}
    end
  end


  ########################
  # APPROOV TOKEN FETCH
  ########################

  # For when the Approov token is the header of a regular HTTP Request
  defp _get_approov_token(%Plug.Conn{} = conn) do
    case Plug.Conn.get_req_header(conn, "x-approov-token") do
      [] ->
        Logger.info("Approov token not in the headers. Next, try to retrieve from url query params.")
        Logger.info(%{headers: conn.req_headers, params: conn.params})
        _get_approov_token(conn.params)

      [approov_token | _] ->
        {:ok, approov_token}
    end
  end

  # For when the Approov token is provided in the URL parameters or in a payload.
  defp _get_approov_token(%{"x-approov-token" => approov_token}), do: {:ok, approov_token}
  defp _get_approov_token(%{"X-Approov-Token" => approov_token}), do: {:ok, approov_token}

  defp _get_approov_token(%{x_headers: x_headers}) when is_list(x_headers) do
    case Utils.filter_list_of_tuples(x_headers, "x-approov-token") do
      nil ->
        {:ok, Utils.filter_list_of_tuples(x_headers, "X-Approov-Token")}

      approov_token ->
        {:ok, approov_token}
    end
  end

  # For when is not possible to retrieve the Approov token.
  defp _get_approov_token(_params) do
    {:error, :missing_approov_token}
  end


  ########################
  # APPROOV TOKEN CHECK
  ########################

  defp _decode_and_verify(approov_token) do
    secret = Application.fetch_env!(:todo, ApproovToken)[:secret_key]

    # call `verify_and_validate/2` injected by `use Joken.Config`
    case verify_and_validate(approov_token, Joken.Signer.create("HS256", secret)) do
      {:ok, %{"exp" => _expiration}} = result ->
        result

      # The library only checks the `exp` when present, and verifies successfully
      # without it, and doesn't have an option to enforce it.
      {:ok, _claims} ->
        {:error, :missing_expiration_time}

      result ->
        result
    end
  end

end
```

### Approov Token Check for HTTP

Now, add the [Approov Token Plug](/src/approov-protected-server/token-check/todo/lib/todo_web/plugs/approov_token_plug.ex) module to your project at `lib/your_app_web/plugs/approov_token_plug.ex`:

```elixir
defmodule YourAppWeb.ApproovTokenPlug do
  require Logger

  ##############################################################################
  # Adhere to the Phoenix Module Plugs specification by implementing:
  #   * init/1
  #   * call/2
  #
  # @link https://hexdocs.pm/phoenix/plug.html#module-plugs
  ##############################################################################

  # Don't use this function to init the Plug with the Approov secret, because
  # this is only evaluated at compile time, and we don't want the to have
  # secrets inside a release. Secrets must always be retrieved from the
  # environment where the release is running.
  def init(opts), do: opts

  # Allows to use the GraphqiQL web interface without requiring the Approov
  # token that is required for all requests in production.
  if Mix.env() in [:dev, :test] do
    # Allows to load the web interface for GraphiQL at `example.com/graphiql`
    # without checking for the Approov token.
    def call(%{method: "GET", request_path: "/graphiql"} = conn, _options), do: conn

    # The GraphqiQL web interface does some introspection queries to help with
    # validation and auto-completion, therefore we must allow them without
    # the need for an Approov token.
    def call(%{method: "POST", request_path: "/graphiql", params: %{"query" => "\n  query IntrospectionQuery" <> _query}} = conn, _options), do: conn
  end

  def call(conn, _opts) do
    case ApproovToken.verify_token(conn) do
      {:ok, approov_token_claims} ->
        conn
        |> Plug.Conn.put_private(:approov_token_claims, approov_token_claims)

      {:error, _reason} ->
        conn
        |> _halt_connection()
    end
  end

  # When the Approov token validation fails we return a `401` with an empty body,
  # because we don't want to give clues to an attacker about the reason the
  # request failed, and you can go even further by returning a `400`. Feel free
  # to modify as you see fits best your use case.
  defp _halt_connection(conn) do
    conn
    |> Plug.Conn.put_status(401)
    |> Phoenix.Controller.json(%{})
    |> Plug.Conn.halt()
  end
end
```

Next, create and use the pipeline for the Approov token check at `lib/your_app_web/router.ex`:

```elixir
pipeline :approov_token do
  # Ideally you will not want to add any other Plug before the Approov Token
  # check to protect your server from wasting resources in processing requests
  # not having a valid Approov token. This increases availability for your
  # users during peak time or in the event of a DoS attack(We all know the
  # BEAM design allows to cope very well with this scenarios, but best to play
  # in the safe side).
  plug YourAppWeb.ApproovTokenPlug
end

pipeline :graphql do
  plug YourAppWeb.AbsintheContextPlug
end

scope "/auth" do
  pipe_through :api
  pipe_through :approov_token

  post "/signup", YourAppWeb.AuthController, :signup
  post "/login", YourAppWeb.AuthController, :login
end

# The `/graphiql` endpoint exposes too much to attackers, thus it shouldn't
# be available in production.
if Mix.env() in [:dev, :test] do
  scope "/graphiql" do
    pipe_through :approov_token
    pipe_through :graphql

    forward "/", Absinthe.Plug.GraphiQL,
      schema: YourAppWeb.Schema,
      socket: YourAppWeb.UserSocket,
      log: false
  end
end

# Needs to be after the /graphiql endpoint scope, otherwise we get this API,
# instead of the expected /graphiql web interface.
scope "/" do
  pipe_through :api
  pipe_through :approov_token
  pipe_through :graphql

  forward "/", Absinthe.Plug,
    schema: YourAppWeb.Schema,
    log: false
end
```

### Approov Token Check for Websockets

This step is only necessary if you want to protect the HTTPS request to establish a socket connection, like when Absinthe subscriptions or Phoenix Channels are used.

Unfortunately the Phoenix socket implementation only allows to retrieve headers from the HTTPS request establishing the socket connection when they start with an `x`, also known as the prefix for non standard HTTP headers.

To enable retrieving the `x` headers, add `connect_info: [:x_headers]` to your socket configuration in the file `endpoint.ex`. It should look similar to this:

```elixir
# lib/your_app_web/endpoint.ex

socket "/socket", YourAppWeb.UserSocket,
  websocket: [
    compress: true,
    connect_info: [
      :x_headers, # ADD THIS LINE TO YOUR WEBSOCKET CONFIGURATION
    ],
  ],
```

> **NOTE:** Putting sensitive data in an URL query parameter is not a best security practice, thus you should avoid as much as possible to put it there. You may think that once the request is over HTTPS it isn't an issue, but you need to remember that the full URL, including the query parameters, are often logged by applications, load balancers, API gateways, etc., thus causing any sensitive data on them to be leaked to the logs. Attackers usually build their attacks based on a chain of exploits, like getting the token from a compromised logging server and subsequently use it on automated or manual attacks. Just search in `shodan.io` for your logging server of choice to see how many are left accidentally publicly exposed to the internet, and attackers have automated tools scanning non-stop for them.

This will enable to retrieve the `X-Approov-Token` header from the HTTPS request establishing the socket connection, that will be available under the second parameter in the `connect/2` callback when implementing the `PhoenixSocket` behaviour, that usually is named as `connect_info`. For example:

```elixir
# lib/your_app_web/channels/user_socket.ex

defmodule YourAppWeb.UserSocket do
  use Phoenix.Socket

  use Absinthe.Phoenix.Socket, schema: YourAppWeb.Schema

  @impl true
  def connect(params, socket, connect_info) do
    socket
    |> _authorize(params, connect_info)
  end

  @impl true
  def id(_socket), do: nil

  defp _authorize(socket, params, connect_info) do

    # We need to merge them because the requests from the GraphiQL web interface
    # doesn't populate the `connect_info` with the Approov token.
    headers = Map.merge(params, connect_info)

    # Always perform the Approov token check before the User Authentication.
    with {:ok, _approov_token_claims} <- ApproovToken.verify_token(headers),
         {:ok, current_user} <- Todos.User.authorize(params: params) do

      socket = Absinthe.Phoenix.Socket.put_options(socket, context: %{current_user: current_user})

      {:ok, socket}
    else
      {:error, _reason} ->
        :error
    end
  end
end
```

Not enough details in the bare bones quickstart? No worries, check the [detailed quickstarts](QUICKSTARTS.md) that contain a more comprehensive set of instructions, including how to test the Approov integration.


## More Information

* [Approov Overview](OVERVIEW.md)
* [Detailed Quickstarts](QUICKSTARTS.md)
* [Step by Step Examples](EXAMPLES.md)
* [Testing](TESTING.md)

### System Clock

In order to correctly check for the expiration times of the Approov tokens is very important that the backend server is synchronizing automatically the system clock over the network with an authoritative time source. In Linux this is usually done with a NTP server.


## Issues

If you find any issue while following our instructions then just report it [here](https://github.com/approov/quickstart-elixir-phoenix-absinthe-graphql-token-check/issues), with the steps to reproduce it, and we will sort it out and/or guide you to the correct path.


## Useful Links

If you wish to explore the Approov solution in more depth, then why not try one of the following links as a jumping off point:

* [Approov Free Trial](https://approov.io/signup)(no credit card needed)
* [Approov Get Started](https://approov.io/product/demo)
* [Approov QuickStarts](https://approov.io/docs/latest/approov-integration-examples/)
* [Approov Docs](https://approov.io/docs)
* [Approov Blog](https://approov.io/blog/)
* [Approov Resources](https://approov.io/resource/)
* [Approov Customer Stories](https://approov.io/customer)
* [Approov Support](https://approov.io/contact)
* [About Us](https://approov.io/company)
* [Contact Us](https://approov.io/contact)
