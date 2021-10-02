defmodule HogwartsTest do
  use ExUnit.Case
  doctest Hogwarts

  test "greets the world" do
    assert Hogwarts.hello() == :world
  end
end
