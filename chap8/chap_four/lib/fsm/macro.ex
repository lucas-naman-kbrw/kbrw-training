defmodule ModifiedMacro do
  defp concatenate_atom(a, b) do
    Atom.to_string(a)<>Atom.to_string(b) |> String.to_atom
  end

  defmacro defmodified({name, env, param}, blocks) do
    {:def, env, [{concatenate_atom(:macroed_, name), env, param}, blocks]}
  end
end

defmodule User do 
  require ModifiedMacro
  import ModifiedMacro 
  
  defmodified my_function(a,b) do 
    a+b
  end 
end

