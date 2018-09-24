defmodule ElixirListWeb.PageController do
  use ElixirListWeb, :controller
  require Logger

  def index(conn, _params) do
    contents = ElixirList.parse_contents()
    list = ElixirList.parse_list()
    render conn, "index.html", contents: contents, list: list
  end
end
