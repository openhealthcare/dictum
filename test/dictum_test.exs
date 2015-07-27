defmodule DictumTest do
  use ExUnit.Case
  alias Dictum.Rules.Server
  alias Dictum.Rules.Rule
  alias Dictum.Rules.RuleInput

  test "add a rule" do
    r = Rule.new("test", "test")
    assert Server.add_rule(:ruleserver, r) == :ok

    r2 = Server.get_rule(:ruleserver, "test/rules/default.rule")
    assert "test/rules/default.rule" = r2.name
    assert ["When \"diagnosis\" was \"CAP\""] = r2.content
  end

  test "evaluate rules" do
    inp = RuleInput.new(%{}, %{})
    Server.eval_rules(:ruleserver, inp)
  end


end
