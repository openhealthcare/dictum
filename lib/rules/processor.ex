defmodule Dictum.Rules.Processor do
  alias Dictum.Rules.Rule
  alias Dictum.Rules.RuleInput
  alias Dictum.Rules.Steps

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
                  {ok, log} = eval_line(rule.name, x, input)
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


  defp eval_line(filename, line, input = %RuleInput{}) do
    # Should return True if the line was evalualted.  If we return false
    # then the following rules will not be processed.
    params = parse_sentence(line)
    [f | args] = params
    try do
      {status, msg} = apply(Steps, func_name(f), ["", args, {"", input.pre, input.post, ""}] )
      log = case status do
        :ok ->
          ""
        :fail ->
          msg
      end
      {status==:ok, log}
    rescue
      x ->
        {false, "Failed to process line: #{line}"}
    end

  end


  def parse_sentence(sentence) do
    Enum.map(Regex.scan(~r/[^\s"]+|"([^"]*)"/, sentence), &(hd(&1)))
    |> Enum.map(fn(x) ->
        case String.match?(x, ~r/\".*\"/) do
            true -> String.replace("#{x}", "\"", "")
            false -> create_atom(String.downcase(x))
        end
    end)
  end

  defp create_atom(str) do
    try do
      String.to_existing_atom(str)
    rescue
      _ -> String.to_atom(str)
    end
  end

  def func_name(str) do
    case str do
        :when ->
            :when_
        :and ->
            :when_
        _ ->
            str
    end
  end

end