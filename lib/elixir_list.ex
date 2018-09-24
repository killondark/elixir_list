defmodule ElixirList do
  @url_for_elixir_list "https://github.com/h4cc/awesome-elixir"
  @ttl 1
  @parse_error "Something went wrong. Can not parse the table of contents"

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
      _ -> @parse_error
    end
  end

  def parse_list do
    html_doc = read_or_load()
    map = Regex.named_captures(~r/(?<result><h2><a id="user-content[\s\S]*?)<h1><a id="user-content-resources"/, html_doc)
    case map do
      %{"result" => string} when not_empty_string(string) ->
        map["result"] |> update_h2()  |> add_info()
      _ -> @parse_error
    end
  end

  def update_h2(string) do
    regex = ~r/<h2>[\s\S]*?<\/a>([\s\S]*?)<\/h2>/
    good_h2 = fn (_, x) ->
      "<h2 id=\"#{String.downcase(x) |> String.replace(" ", "-")}\">#{x}</h2>"
    end
    Regex.replace(regex, string, good_h2)
  end

  def repo_info(url) do
    # curl https://api.github.com/repos/[username]/[reponame]
    # last_commit: "updated_at"
    # stars: "stargazers_count"
    # HTTPoison.get!("https://api.github.com/repos/takscape/elixir-array", [], [params: [access_token: "auth-token"]])
    options = [params: [access_token: "generate-token"]]
    response = HTTPoison.get!(url, [], options)
    req = Poison.decode!(response.body)
    %{last_commit: req["updated_at"], stars: req["stargazers_count"]}
  end

  def add_info(string) do
    regex = ~r/<li><a href=\"([\s\S]*?)\">[\s\S]*?<\/a>/
    data = fn (all, link) ->
      # curl -i https://api.github.com -u login:password
      # curl https://api.github.com/?access_token=OAUTH-TOKEN
      good_link = Regex.replace(~r/https:\/\/github.com/, link, "https://api.github.com/repos")
      if String.contains?(good_link, "github") do
        info = repo_info(good_link)
        "#{all} stars: #{info.stars}, last_commit: #{info.last_commit}"
      else
        all
      end
    end
    Regex.replace(regex, string, data)
  end
end
