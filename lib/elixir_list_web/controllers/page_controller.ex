defmodule ElixirListWeb.PageController do
  use ElixirListWeb, :controller
  require Logger

  def index(conn, _params) do
    titles = ElixirList.select_titles()
    Logger.info("Titles: #{titles}")
    render conn, "index.html", titles: titles
  end
end
