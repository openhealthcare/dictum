defmodule Dictum.Rules.Rule do
  defstruct name: "", lines: ""

  def new(name, lines) when is_list(lines) do
    %__MODULE__{:name=> name, :lines=>lines}
  end

  def new(name, text) do
    %__MODULE__{:name=> name, :lines=>String.split(text, "\n", trim: true)}
  end

end

defmodule Dictum.Rules.RuleInput do
  defstruct pre: %{}, post: %{}, context: %{}

  def new(pre, post) do
    %__MODULE__{:pre=> pre, :post=>[post]}
  end

  def reset(input) do
    %{input| :context => %{}}
  end

end