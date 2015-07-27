defmodule Dictum.Rules.Processor do
  alias Dictum.Rules.Rule
  alias Dictum.Rules.RuleInput

  def eval(rule = %Rule{:content=>content}, input = %RuleInput{} ) when length(content) == 0 do
    {rule.name, false, ["No rule content to process"]}
  end


  def log_collector(logs) do
    result = receive do
      {:entry, entry} ->
        log_collector([entry|logs])
      {:stop} ->
        List.flatten(Enum.reverse(logs))
    end
    result
  end

  def eval(rule = %Rule{:content=>content}, input = %RuleInput{} ) when length(content) > 0 do
    # Iterate through each line in the rule contents and evaluate
    # whether it resolves to true or false.  If it is false, we're done,
    # otherwise we probably have an action to take (the 'Then' clause).

    task = Task.async(__MODULE__, :log_collector, [[]])

    takes = rule.content
            |>  Enum.take_while(fn(x) ->
                  {ok, log} = eval_line(x, input)
                  case log do
                    "" ->
                      ok
                    _ ->
                      send(task.pid, {:entry, [log]})
                      ok
                  end
                end)

    send( task.pid, {:stop})
    logs = Task.await(task)

    # Success is length takes == length rule.content
    # at which point we have already run the action.  If length takes is
    # ever shorted than the rule lines it means one of them returned false

    {rule.name, length(takes) == length(rule.content), logs}
  end

  defp eval_line(line, input = %RuleInput{}) do
    # Should return True if the line was evalualted.  If we return false
    # then the following rules will not be processed.
    {false, "Rule failed"}
  end


end