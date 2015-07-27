defmodule Dictum.Rules.Processor do
  alias Dictum.Rules.Rule
  alias Dictum.Rules.RuleInput

  def eval(rule = %Rule{}, input = %RuleInput{} ) do
    # Iterate through each line in the rule contents and evaluate
    # whether it resolves to true or false.  If it is false, we're done,
    # otherwise we probably have an action to take (the 'Then' clause).
    takes = rule.content
            |>  Enum.take_while(fn(x) -> eval_line(x, input) end)

    # Success is length takes == length rule.content
    # at which point we have already run the action.  If length takes is
    # ever shorted than the rule lines it means one of them returned false

    "Something was done ..."
  end

  defp eval_line(line, input = %RuleInput{}) do
    # Should return True if the line was evalualted.  If we return false
    # then the following rules will not be processed.
    false
  end


end