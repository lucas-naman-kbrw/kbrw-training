defmodule TutoKbrwStack do

  def hello do
    :world
  end

  def start(_type, _args) do
    Server.Supervisor.start_link
  end

end
