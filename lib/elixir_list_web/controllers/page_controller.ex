defmodule ElixirListWeb.PageController do
  use ElixirListWeb, :controller
  require Logger

  def index(conn, _params) do
    html_doc = ElixirList.read_or_load()
    Logger.info(html_doc)
    render conn, "index.html", html_doc: html_doc
  end
end
