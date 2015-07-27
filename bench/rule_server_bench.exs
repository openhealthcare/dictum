defmodule RuleServerBench do
  use Benchfella
  alias Dictum.Rules.Server
  alias Dictum.Rules.Rule
  alias Dictum.Rules.RuleInput

 setup_all do
    pid = GenServer.start_link(Server, :ok, name: :testruleserver)

    for x <- :lists.seq(1, 1000) do
      :ok = Server.add_rule(:testruleserver, Rule.new("test#{x}", "test#{x}") )
    end
    {:ok, pid}
  end

  bench "ruleserver fetch rule" do
    Server.get_rule(:testruleserver, "test")
  end

  bench "evaluate rules" do
    # There should be 1000 rules to iterate through and check
    inp = RuleInput.new(%{}, %{})
    Server.eval_rules(:testruleserver, inp)
  end

end