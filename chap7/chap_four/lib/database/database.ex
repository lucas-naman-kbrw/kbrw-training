defmodule Server.Database do
  use GenServer

  # Client Side
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get_table do
    GenServer.call(__MODULE__, :get_table)
  end

  def get_row( key) do
    GenServer.call(__MODULE__, {:get_row, key})
  end

  def insert_row(row) do
    GenServer.cast(__MODULE__, {:insert_row, row})
  end

  def delete_row(row) do
    GenServer.cast(__MODULE__, {:delete_row, row})
  end

  def search(_database, criteria) do
    list = :ets.tab2list(:table)
    valids_items = Enum.filter(list, fn {key, item} -> length(Enum.filter(criteria, fn {key, value}-> item[key] == value end)) > 0 end)
    Enum.map(valids_items, fn {key, value}-> value end)
  end

  # Server Side / Callbacks
  def init(table) do
    :ets.new(:table, [:named_table])
    {:ok, table}
  end

  def handle_call(:get_table, _form, _table) do
    {:reply, :ets.tab2list(:table), :ets.tab2list(:table)}
  end

  def handle_call({:get_row, key}, _form, _table) do
    {:reply, :ets.lookup(:table, key), :ets.lookup(:table, key)}
  end

  def handle_cast({:insert_row, row}, _table) do
    {:noreply, :ets.insert(:table, row)}
  end

  def handle_cast({:delete_row, {key, _value}}, _table) do
    {:noreply, :ets.delete(:table, key)}
  end

end
