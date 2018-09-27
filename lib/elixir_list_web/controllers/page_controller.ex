defmodule ElixirListWeb.PageController do
  use ElixirListWeb, :controller
  require Logger

  def index(conn, _params) do
    data = conn.params
    |> Map.get("min_stars")
    |> case do
      value when is_binary(value) ->
        case Integer.parse(value) do
          :error -> 0
          {n, _} -> n
        end
      _ -> 0
    end
    |> ElixirList.select_gt_stars()
    titles = ElixirList.select_titles(data)
    render conn, "index.html", titles: titles, data: data
  end
end
