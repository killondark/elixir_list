defmodule ElixirListWeb.PageController do
  use ElixirListWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
