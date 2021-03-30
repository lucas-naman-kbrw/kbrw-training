{:ok, pid} = GenServer.start_link(Fsm.Payment, "nat_order000147707")
GenServer.call(pid, :process_payment)