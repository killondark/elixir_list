defmodule ElixirList do
  @url_for_elixir_list "https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md"

  def download_file do
    Download.from(@url_for_elixir_list, [path: file_path()])    
  end

  def open_file(path) do
    File.read! path
  end

  def file_path do
    "#{File.cwd!}/list_from_github.md"
  end
end
