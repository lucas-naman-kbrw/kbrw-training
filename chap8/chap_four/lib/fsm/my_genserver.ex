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
    def init(order_id) do
        order = Server.Database.get_row(order_id)
        {id, order_map} = hd(order)
        {:ok, order_map}
    end

    @impl true
    def handle_call(:process_payment, _form, order) do
        {:next_state, {old_state, updated_order}} = ExFSM.Machine.event(order, {:process_payment, []})
        {:next_state, {old_state, updated_order}} = ExFSM.Machine.event(updated_order, {:verfication, []})
        # IO.inspect MyRulex.apply_rules(%{"payment_method" => "paypal"}, order)
        {:reply, updated_order , updated_order}
    end
end
