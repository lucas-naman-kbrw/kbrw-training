defmodule ChapTwoTest do
  use ExUnit.Case
  doctest ChapTwo

  test "greets the world" do
    assert ChapTwo.hello() == :world
  end
end
