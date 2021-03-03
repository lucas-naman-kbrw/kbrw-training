{:ok, pid} = Server.Database.start_link
Server.Database.insert_row({"a", 2})
Server.Database.insert_row({"b", 3})
Server.Database.get_table
Server.Database.insert_row({"b", 5})
Server.Database.get_row("b")
Server.Database.delete_row({"b", 5})
Server.Database.get_table



JsonLoader.load_to_database("", "./orders_dump/orders_chunk0.json")
Server.Database.search("", [{"id", "nat_order000147679"}])
Server.Database.search("", [{"type", "nat_order"}])
