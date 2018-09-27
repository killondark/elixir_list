defmodule ElixirListWeb.PageView do
  use ElixirListWeb, :view

  def get_id(string) do
    String.downcase(string) |> String.replace(" ", "-")
  end
end
