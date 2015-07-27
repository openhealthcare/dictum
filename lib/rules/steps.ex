defmodule Dictum.Rules.Steps do
  alias Dictum.Utils.MapTraversal

  def resolve_var(x), do: x

  @doc"""
  For a nested series of JSON objects MAP, find out if there is a
  property KEY with VALUE.

  KEY will be expressed as foo.bar.baz
  """
  def json_property_matches(key, map, value) do
    MapTraversal.map_apply(key, map, value,
      fn(x) -> Enum.any?(x, fn(y) -> y == value end) end,
      fn(x) -> x == value end)
  end

  """
  For a nested series of JSON objects MAP, find out if there is a
  property KEY with a value that contains VALUE.

  KEY will be expressed as foo.bar.baz
  """
  defp json_property_contains(key, map, value) do
    MapTraversal.map_apply(key, map, value,
      fn(x) -> Enum.any?(x, fn(y) -> String.contains? String.downcase(y), String.downcase(value) end) end,
      fn(x) -> String.contains? x, value end)
  end

  defp provide_result(success, err , {_action, pre, post, endpoint}) do
      case success do
        true ->
          {:ok, {pre,post, endpoint}}
        false ->
          {:fail, err}
      end
  end

  def when_(_behaviour, [key, :is, value], {action, pre, post, endpoint}) do
      match = json_property_matches key, post, resolve_var(value)
      provide_result match, "Does not match", {action, pre, post, endpoint}
  end

  def when_(_behaviour, [key, :is, :not, value], {action, pre, post, endpoint}) do
      match = json_property_matches key, post, resolve_var(value)
      provide_result !match, "Does not match", {action, pre, post, endpoint}
  end

  def when_(_behaviour, [key, :was, value], {action, pre, post, endpoint}) do
      match = json_property_matches key, pre, resolve_var(value)
      provide_result match, "Does not match", {action, pre, post, endpoint}
  end

  def when_(_behaviour, [key, :was, :not, value], {action, pre, post, endpoint}) do
      match = json_property_matches key, pre, resolve_var(value)
      provide_result !match, "Does not match", {action, pre, post, endpoint}
  end

  def when_(_behaviour, [key, :did, :contain, value], {action, pre, post, endpoint}) do
    match = json_property_contains key, pre, resolve_var(value)
    provide_result match, "Does not match", {action, pre, post, endpoint}
  end

  def when_(_behaviour, [key, :did, :not, :contain, value], {action, pre, post, endpoint}) do
    match = json_property_contains key, pre, resolve_var(value)
    provide_result !match, "Does not match", {action, pre, post, endpoint}
  end

  def when_(_behaviour, [key, :contains, value], {action, pre, post, endpoint}) do
    match = json_property_contains key, post, resolve_var(value)
    provide_result match, "Does not match", {action, pre, post, endpoint}
  end

  def when_(_behaviour, [key, :does, :not, :contain, value], {action, pre, post, endpoint}) do
    match = json_property_contains key, post, resolve_var(value)
    provide_result !match, "Does not match", {action, pre, post, endpoint}
  end

  def when_(_behaviour, [key, :changed, :to, value], {action, pre, post, endpoint}) do
    was = json_property_matches( key, pre, resolve_var(value))
    is = json_property_matches key, post, resolve_var(value)
    match = !was and is
    provide_result match, "Does not match", {action, pre, post, endpoint}
  end

  def when_(_behaviour, [key, :changed, :from, value], {action, pre, post, endpoint}) do
    was = json_property_matches( key, pre, resolve_var(value))
    is = json_property_matches key, post, resolve_var(value)
    match = was and !is
    provide_result match, "Does not match", {action, pre, post, endpoint}
  end

  def when_(_behaviour, [key, :changed, :from, value, :to, new_value], {action, pre, post, endpoint}) do
    was = json_property_matches( key, pre, resolve_var(value))
    is = json_property_matches key, post, resolve_var(new_value)
    match = was and is
    provide_result match, "Does not match", {action, pre, post, endpoint}
  end

  def when_(_behaviour, [:admitted, :to, ward], {:admit, pre, post, endpoint}) do
    match = json_property_matches "location.ward", post, resolve_var(ward)
    provide_result match, "Does not match", {:admit, pre, post, endpoint}
  end

  def when_(_behaviour, [kold, :intersects, knew], {action, pre, post, endpoint}) do
    first = MapTraversal.find_value(kold, post)
    second = MapTraversal.find_value(knew, post)

    intersection =  Set.intersection(Enum.into(first, HashSet.new),
                                     Enum.into(second, HashSet.new))
    provide_result HashSet.size(intersection) > 0, "There is no intersection", {action, pre, post, endpoint}
  end


  def then(_behaviour, [h|t], {action, pre, post, endpoint}) do
      # We want to apply the action h and pass t as the args
      # TODO: Do this in a separate process so that we're not blocking this
      # process. It doesn't matter that we're currently blocking, but no need
      # to keep it alive longer than necessary. This might mean the action
      # has to handle it's own logging.
      # pid = spawn Actions, h, [_behaviour, t, {action, pre, post, endpoint}]

      #try do
      #  apply(Actions, h, [_behaviour, t, {action, pre, post, endpoint}])
      #rescue
      #  e -> IO.inspect e
      #end
  end

end