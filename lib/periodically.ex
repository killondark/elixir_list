defmodule Periodically do
  use GenServer

  @run_now 1000
  @sec_per_day 86400

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:update, state) do
    ElixirList.update_lib_data()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    # 1 * 60 * 60 * 1000 # In 1 hours
    time = check_time()
    Process.send_after(self(), :update, time)
  end

  def check_time do
    case ElixirList.get_datetime() do
      [[datetime]] -> 
        case ElixirList.time_difference(datetime) do
          {0, time} -> (@sec_per_day - ElixirList.time_to_seconds(time)) * 1000
          _ -> @run_now
        end
      _ -> @run_now
    end
  end
end