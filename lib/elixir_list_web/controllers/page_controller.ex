defmodule ElixirListWeb.PageController do
  use ElixirListWeb, :controller
  require Logger

  def index(conn, _params) do
    render conn, "index.html", contents: ElixirList.parse_contents()
  end
end
