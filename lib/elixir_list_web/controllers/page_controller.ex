defmodule ElixirListWeb.PageController do
  use ElixirListWeb, :controller
  require Logger

  def index(conn, _params) do
    ElixirList.download_file()
    markdown = ElixirList.open_file(ElixirList.file_path())
    {_, html_doc, _}     = ElixirList.md_to_html(markdown)
    render conn, "index.html", html_doc: html_doc
  end
end
