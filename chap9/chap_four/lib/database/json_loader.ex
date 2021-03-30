defmodule JsonLoader do

  def load_to_database(_database, json_file) do
    {:ok, file_content} = File.read(json_file)
    {:ok, file_map} = Poison.decode(file_content)
    Enum.map(file_map, fn x when is_map(x) -> add_to_ets(x)  end)
  end

  defp add_to_ets(map) do
    Server.Database.insert_row({map["id"], map})
  end

end
