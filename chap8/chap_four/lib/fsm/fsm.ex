defimpl ExFSM.Machine.State, for: Map do
  def state_name(order), do: String.to_atom(order["status"]["state"])
  def set_state_name(order, name), do: Kernel.get_and_update_in(order["status"]["state"], fn state -> {state, Atom.to_string(name)} end)
  def handlers(order) do
    {fsm, _} = MyRulex.apply_rules(order, [])
    fsm
  end

end

defmodule MyFSM do                                                                                      

  defmodule Paypal do

    use ExFSM

    deftrans init({:payment_done, []}, order) do 
      {:next_state, :paid, order}
    end 

    deftrans init({:payment_error, []}, order) do 
      {:next_state, :payment_error, order}
    end
  end

  defmodule Stripe do
    use ExFSM

    deftrans init({:payment_done, []}, order) do 
        {:next_state, :paid, order}
      end 
      
      deftrans init({:payment_failed, []}, order) do 
        {:next_state, :payment_refused, order}
      end
  end

  defmodule Delivery do
    use ExFSM

    deftrans init({:payment_done, []}, order) do 
        {:next_state, :paid, order}
      end

      deftrans init({:payment_failed, []}, order) do 
        {:next_state, :payment_refused, order}
      end
  end

end

defmodule MyRulex do
  use Rulex

  defrule delivery_fsm(%{"payment_methods"=> "delivery"}, acc), do: {:ok, [MyFSM.Delivery | acc]}
  defrule paypal_fsm(%{"payment_methods"=> "paypal"}, acc), do: {:ok, [MyFSM.Paypal | acc]}
  defrule stripe_fsm(%{"payment_methods"=> "stripe"}, acc), do: {:ok, [MyFSM.Stripe | acc]}

end