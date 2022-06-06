defmodule ExMatchersTest do
  use ExUnit.Case, async: true
  use ExMatchers

  import TestMatcher

  test "the ~> operator is defined and returns success" do
    assert 1 ~> 1
  end

  test "the ~> operator is defined and returns failure" do
    refute 1 ~> 0
  end

  test "the ~>> operator returns mismatches" do
    assert 1
           ~>> test_matcher(behaviour: :always_mismatch)
           ~> [%ExMatchers.Mismatch{message: "Always mismatch", path: []}]
  end

  test "the ~>> operator returns empty list when matcher returns empty list" do
    assert 1 ~>> test_matcher(behaviour: :match_returning_list) ~> []
  end

  test "the ~>> operator returns empty list when matcher returns nil" do
    assert 1 ~>> test_matcher(behaviour: :match_returning_nil) ~> []
  end
end
