require('@kbrw/node_erlastic').server(function(term,from,current_amount,done){

    var amount = current_amount;

    if (term == "hello") return done("reply", "Hello World!");
    if (term == "what") return done("reply", "what! What ?");

    if (term == "kbrw") {
      done("noreply",current_amount-2)
      return done("reply",current_amount);
    }

    if (term[0] == "kbrw") return done("noreply",current_amount+term[1]);

    throw new Error("unexpected request")
  });