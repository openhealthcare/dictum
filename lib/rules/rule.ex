defmodule Dictum.Rules.Rule do
  defstruct name: "", content: ""

  def new(name, text) when is_list(text) do
    %__MODULE__{:name=> name, :content=>text}
  end

  def new(name, text) do
    %__MODULE__{:name=> name, :content=>String.split(text, "\n", trim: true)}
  end

end

defmodule Dictum.Rules.RuleInput do
  defstruct pre: %{}, post: %{}

  def new(pre, post) do
    %__MODULE__{:pre=> pre, :post=>[post]}
  end

end