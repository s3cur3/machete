defmodule IntegerMatcherTest do
  use ExUnit.Case, async: true

  import ExMatchers

  test "matches integers" do
    assert 1 ~> integer()
  end
end
