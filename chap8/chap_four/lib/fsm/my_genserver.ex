defmodule Fsm.Payment do
  use GenServer

    # Server Side / Callbacks
    @impl true
    def init(order_id) do
        order = Server.Database.get_row(order_id)
        {id, order_map} = hd(order)
        {:ok, order_map}
    end

    @impl true
    def handle_call(:process_payment, _form, order) do
        # {:next_state, {old_state, updated_order}} = 
        # ExFSM.Machine.event(order, {:payment_done, []})
        resp = case ExFSM.Machine.event(order, {:payment_done, []}) do
            {:next_state, {_old_state, updated_order}} -> 
                Server.Database.insert_row({updated_order["id"], updated_order})
                updated_order
            {:error, :illegal_action} -> 
                order
        end
        {:reply, resp , resp}
    end
end
