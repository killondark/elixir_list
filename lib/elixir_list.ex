defmodule ElixirList do
  require Logger

  @url_for_elixir_list "https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md"
  @ttl 1
  @parse_error "Something went wrong. Can not parse the table of contents"

  def update_lib_data do
    parse_awesome_elixir() |> raw_contents() |> parse_contents()
  end
  
  def parse_awesome_elixir do
    HTTPoison.get!(@url_for_elixir_list).body
  end

  def raw_contents(string) do
    string = Regex.replace(~r/([\s\S]*?)\n##/, string, "\n##", global: false)
    Regex.replace(~r/\n(# Resources[\s\S]*)/, string, "\n##")
    # result <> "##"
  end

  def parse_lib(string) do
    Regex.scan(~r/\* [\s\S]*?\(https:\/\/github.com\/([\s\S]*?)\/?\) - ([\s\S]*?)\n/, string)
  end

  def set_repo_info(repo) do
    # curl https://api.github.com/repos/[username]/[reponame]
    # last_commit: "updated_at"
    # stars: "stargazers_count"
    # HTTPoison.get!("https://api.github.com/repos/takscape/elixir-array", [], [params: [access_token: "auth-token"]])
    options = [params: [access_token: "generate-token"]]
    if options[:params][:access_token] == "generate-token" do
      Logger.info("You need generate token")
    end
    response = HTTPoison.get!("https://api.github.com/repos/" <> repo, [], options)
    req = Poison.decode!(response.body)
    case response.status_code do
      404 -> [nil, nil]
      301 ->
        response = HTTPoison.get!(req["url"])
        req = Poison.decode!(response.body)
        stars_and_commit_date(req)
      _ -> stars_and_commit_date(req)
    end
  end

  def stars_and_commit_date(data) do
    last_commit = parse_commit_date(data["updated_at"])
    {day_from_last_commit, _} = time_difference(last_commit)
    [data["stargazers_count"], day_from_last_commit]
  end

  def parse_commit_date(string) do
    Logger.info(string)
    data = Regex.scan(~r/\d+/, string) |> List.flatten()
    [year, month, day, hours, minutes, seconds] = Enum.map(data, fn x -> String.to_integer(x) end)
    {{year, month, day}, {hours, minutes, seconds}}
  end

  def time_difference(time) do
    :calendar.time_difference(time, :calendar.universal_time)
  end 

  def parse_contents(string) do
    regex = ~r/(\n## [\s\S]*?)\n##/
    if Regex.match?(regex, string) do
      [_, block_of_contents] = Regex.run(regex, string)
      [_, title_name] = Regex.run(~r/\n## ([\s\S]*?)\n/, block_of_contents)
      [_, title_description] = Regex.run(~r/\n\*([\s\S]*?)\*/, block_of_contents)
      libs = parse_lib(block_of_contents)
      libs = Enum.map(libs, fn x ->
        x = List.delete_at(x, 0)
        x ++ (hd(x) |> ElixirList.set_repo_info())
      end)
      record = {title_name, title_description, :calendar.universal_time, libs}
      create(record)
      string = Regex.replace(regex, string, "\n##", global: false)
      parse_contents(string)
    end
  end

  def all_records do
    :dets.match_object(store_name(), {:"$1", :"$2", :"$3", :"$4"})
  end

  def store_name do
    Application.get_env(:elixir_list, ElixirListWeb.Endpoint)[:dets]
  end

  def open_table do
    :dets.open_file(store_name(), [type: :set])
  end

  def create(data) do
    :dets.insert(store_name(), data)
  end

  def select_titles do
    :dets.match(store_name(), {:"$1", :_, :_, :_})
    |> List.flatten()
    |> Enum.sort()
  end
end
