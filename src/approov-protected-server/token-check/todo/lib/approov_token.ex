defmodule ApproovToken do
  require Logger

  use Joken.Config

  @impl Joken.Config
  def token_config, do: default_claims(skip: [:aud, :iat, :iss, :jti, :nbf])

  # Verifies the token from an HTTP request or from a Websockets connection/event
  def verify_token(params) do
    Logger.info(%{verify_approov_token_params: params})

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

  # For a Phoenix Channel event, where the token is provided in the event payload.
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

  # Catch failure to fetch the Approov token from the WebSocket upgrade request
  # or from the Phoenix Channel event.
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
