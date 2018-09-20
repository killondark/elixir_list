defmodule ElixirList do
  @url_for_elixir_list "https://github.com/h4cc/awesome-elixir"
  @ttl 1

  defguard not_empty_string(string) when is_binary(string) and string != ""
  
  def download_file do
    # does not overwrite file if he is exist
    Download.from(@url_for_elixir_list, [path: file_path()])    
  end

  def open_file do
    File.read!(file_path())
  end

  def file_path do
    "#{File.cwd!}/raw_github_list.html"
  end

  def read_file_info do
    case :file.read_file_info(file_path()) do
      {:ok, file_info} ->
        File.Stat.from_record(file_info)
      {:error, _} ->
        download_file()
        read_file_info()
    end
  end

  def last_download do
    create_time = read_file_info().mtime
    time_now = :calendar.local_time()
    :calendar.time_difference(create_time, time_now)
  end  

  def read_or_load do
    {days, _} = last_download()
    if days >= @ttl do
      delete_file()
      download_file()
    end
    open_file()
  end

  def delete_file do
    :file.delete(file_path())
  end

  def parse_contents do
    html_doc = read_or_load()
    map = Regex.named_captures(~r/<li><a href="#awesome-elixir">Awesome Elixir<\/a>\n(?<result>[\s\S]*?)<\/ul>/, html_doc)
    case map do
      %{"result" => string} when not_empty_string(string) ->
        map["result"]
      _ -> "Something went wrong. Can not parse the table of contents"
    end
  end
end
