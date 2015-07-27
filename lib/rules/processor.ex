defmodule Dictum.Rules.Processor do
  alias Dictum.Rules.Rule
  alias Dictum.Rules.RuleInput

  def eval(rule = %Rule{:lines=>lines}, input = %RuleInput{} ) when length(lines) == 0 do
    {rule.name, false, ["No rule lines to process"]}
  end


  def log_collector(logs) do
    result = receive do
      {:entry, entry} ->
        case entry do
          "" -> log_collector(logs)
          _  -> log_collector([entry|logs])
        end
      {:stop} ->
        List.flatten(Enum.reverse(logs))
    end
    result
  end

  def eval(rule = %Rule{:lines=>lines}, input = %RuleInput{} ) when length(lines) > 0 do
    # Iterate through each line in the rule lines and evaluate
    # whether it resolves to true or false.  If it is false, we're done,
    # otherwise we probably have an action to take (the 'Then' clause).

    task = Task.async(__MODULE__, :log_collector, [[]])

    # Reset the context used for passing information through a single ruleset
    RuleInput.reset(input)

    takes = rule.lines
            |>  Enum.take_while(fn(x) ->
                  {ok, log} = eval_line(x, input)
                  send(task.pid, {:entry, [log]})
                  ok
                end)

    send( task.pid, {:stop})
    logs = Task.await(task)

    # Success is length takes == length rule.lines
    # at which point we have already run the action.  If length takes is
    # ever shorter than the rule lines it means one of them returned false

    {rule.name, length(takes) == length(rule.lines), logs}
  end

  defp eval_line(line, input = %RuleInput{}) do
    # Should return True if the line was evalualted.  If we return false
    # then the following rules will not be processed.

    {false, ""}
  end


end