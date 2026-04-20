defmodule ShopifyApp.ShopifyBypass do
  @api_version Application.compile_env(:shopify_api, ShopifyAPI.GraphQL)
               |> Keyword.fetch!(:graphql_version)

  def shopifyapi_bypass(context) do
    bypass =
      Map.get_lazy(context, :bypass, fn ->
        bypass = Bypass.open()
        ExUnit.Callbacks.on_exit(fn -> Bypass.down(bypass) end)
        bypass
      end)

    [bypass: bypass, myshopify_domain: "localhost:#{bypass.port}"]
  end

  def stub(bypass, responses, pid \\ nil) do
    Bypass.stub(
      bypass,
      "POST",
      "/admin/api/#{@api_version}/graphql.json",
      bypass_function(responses, pid)
    )
  end

  def expect_once(bypass, responses, pid \\ nil) do
    Bypass.expect_once(
      bypass,
      "POST",
      "/admin/api/#{@api_version}/graphql.json",
      bypass_function(responses, pid)
    )
  end

  defp bypass_function(responses, pid),
    do: fn conn -> do_bypass_function(conn, responses, pid) end

  defp do_bypass_function(conn, responses, pid) do
    {:ok, request_body, conn} = Plug.Conn.read_body(conn)

    request_body_map = JSON.decode!(request_body)

    {req_handle, response, error} =
      responses
      |> Enum.map(fn
        {req_handle, response} -> {req_handle, response, fn -> nil end}
        {req_handle, response, error} -> {req_handle, response, error}
      end)
      |> Enum.find(
        {nil, "", ["No bypass match found"]},
        fn {req_handle, _response, _func} ->
          String.match?(request_body, Regex.compile!(req_handle))
        end
      )
      |> then(fn {req_handle, response, error} ->
        {req_handle, resolve(response, request_body_map, conn),
         resolve(error, request_body_map, conn)}
      end)

    resp_body =
      case {req_handle, response, error} do
        {_req_handle, response, nil} ->
          Jason.encode!(%{
            "data" => response,
            "extensions" => %{
              "cost" => %{
                "actualQueryCost" => 10,
                "requestedQueryCost" => 10,
                "throttleStatus" => %{
                  "currentlyAvailable" => 1900,
                  "maximumAvailable" => 2000.0,
                  "restoreRate" => 50.0
                }
              }
            }
          })

        {_req_handle, response, error} ->
          Jason.encode!(%{
            "data" => response,
            "errors" => error,
            "extensions" => %{
              "cost" => %{
                "actualQueryCost" => 10,
                "requestedQueryCost" => 10,
                "throttleStatus" => %{
                  "currentlyAvailable" => 1900,
                  "maximumAvailable" => 2000.0,
                  "restoreRate" => 50.0
                }
              }
            }
          })
      end

    if pid do
      send(pid, {req_handle, response, error})
    end

    Plug.Conn.resp(conn, 200, resp_body)
  end

  defp resolve(func, _request_body_map, _conn) when is_function(func, 0), do: func.()

  defp resolve(func, request_body_map, _conn) when is_function(func, 1),
    do: func.(request_body_map)

  defp resolve(func, request_body_map, conn) when is_function(func, 2),
    do: func.(request_body_map, conn)

  defp resolve(value, _request_body_map, _conn), do: value
end
