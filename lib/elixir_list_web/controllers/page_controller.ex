defmodule ElixirListWeb.PageController do
  use ElixirListWeb, :controller

  def index(conn, _params) do
    file = ElixirList.download_file()
    render conn, "index.html"
  end
end
