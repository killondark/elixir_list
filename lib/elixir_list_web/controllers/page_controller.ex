defmodule ElixirListWeb.PageController do
  use ElixirListWeb, :controller
  require Logger

  def index(conn, _params) do
    ElixirList.download_file()
    data = ElixirList.open_file(ElixirList.file_path())
    render conn, "index.html"
  end
end
