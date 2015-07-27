defmodule Dictum.Rules.Server do
  use GenServer
  alias Dictum.Rules.Rule
  alias Dictum.Rules.RuleInput
  alias Dictum.Rules.Processor

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def add_rule(pid, rule = %Rule{}) do
    GenServer.cast(pid, {:add_rule, rule})
  end

  def get_rule(pid, name) do
    GenServer.call(pid, {:get_rule, name})
  end

  def eval_rules(pid, input = %RuleInput{}) do
    GenServer.cast(pid, {:eval, input})
  end

  def load_rules(pid, from_folder) do
    Path.wildcard(from_folder <> "/**/*.rule")
    |> Enum.each(fn x->
      GenServer.cast(pid, {:add_rule, Rule.new(x, File.read!(x))} )
    end)
  end


  #######################################################################
  # Genserver implementation
  #######################################################################

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:get_rule, name}, _from, state) do
    {:reply, %Rule{:name => name, :content => Dict.get(state, name)}, state}
  end

  def handle_cast({:add_rule, rule = %Rule{}}, state) do
    {:noreply, Dict.put(state, rule.name, rule.content)}
  end

  def handle_cast({:eval, input = %RuleInput{}}, state) do
    # Apply all the rules to the input and create a log entry
    # out of the results, removing those that did nothing.
    results = state
      |> Enum.map(fn {k,v}-> Processor.eval(Rule.new(k, v), input) end)
      |> Enum.filter(fn x -> x != nil end)

    {:noreply, state}
  end

end
