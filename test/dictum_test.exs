defmodule DictumTest do
  use ExUnit.Case
  alias Dictum.Rules.Server
  alias Dictum.Rules.Rule
  alias Dictum.Rules.RuleInput

  test "add/delete/get a rule" do
    r = Rule.new("test", "test")
    assert Server.add_rule(:ruleserver, r) == :ok
    assert Server.delete_rule(:ruleserver, "test") == :ok

    r2 = Server.get_rule(:ruleserver, "test/rules/default.rule")
    assert "test/rules/default.rule" = r2.name
    assert ["# Expected to fail due to lack of useful content"] = r2.lines
  end

  test "evaluate rules" do
    inp = RuleInput.new(%{}, %{})
    res = Server.eval_rules_sync(:ruleserver, inp)
          |> Enum.into(%{}, fn {name, success, log} ->
              {name, {success, log}}
          end)

    assert Dict.size(res) == 2

    first = res["test/rules/default.rule"]
    assert elem(first, 0) == false
    assert elem(first, 1) ==  ["Failed to process line: # Expected to fail due to lack of useful content"]
  end

  test "valid match" do
    inp = RuleInput.new(%{}, %{"field1" => "10", "field2" => "20"})
    res = Server.eval_rules_sync(:ruleserver, inp)
          |> Enum.into(%{}, fn {name, success, log} ->
              {name, {success, log}}
          end)

    assert Dict.size(res) == 2
    first = res["test/rules/default/simple.rule"]
    IO.inspect first
  end

end
