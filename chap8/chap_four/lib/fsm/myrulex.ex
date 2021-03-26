defmodule MyRulex do
  use Rulex

  defrule paypal_fsm(%{"payment_method" => "paypal"} = order, acc), do: {:ok, [MyFSM.Paypal | acc]}

end