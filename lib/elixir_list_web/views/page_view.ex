defmodule ElixirListWeb.PageView do
  use ElixirListWeb, :view

  def get_id(string) do
    String.downcase(string) |> String.replace(~r/ | \/ | \( |\)/, "-")
  end

  def lib_name(string) do
    Regex.replace(~r/[\s\S]*?\//, string, "")
  end

  def github_path(name) do
    "https://github.com/" <> name
  end
end
