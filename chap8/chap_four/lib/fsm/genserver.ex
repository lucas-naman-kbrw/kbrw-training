defmodule Fsm.Payment do
  use GenServer

#   # Client Side
#   def start_link do
#     GenServer.start_link(__MODULE__, [], name: __MODULE__)
#   end

#   def process_payment do
#     GenServer.call(__MODULE__, :process_payment)
#   end

    # Server Side / Callbacks
    @impl true
    def init(stack) do
        # order = Server.Database.get_row(order_id)
        # IO.inspect order
        {:ok, stack}
    end

    @impl true
    def handle_call(:process_payment, _form, order) do
        IO.inspect order
        {:reply, :ok , :ok}
    end
end
