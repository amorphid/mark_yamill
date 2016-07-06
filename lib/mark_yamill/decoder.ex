defprotocol MarkYamill.Decoder do
  def decode(data)
end

defimpl MarkYamill.Decoder, for: List do
  alias MarkYamill.Decoder
  alias MarkYamill.Lists

  def decode(list) do
    if :io_lib.printable_unicode_list(list) do
      Decoder.decode(%Lists.Printable{list: list})
    else
      Decoder.decode(%Lists.Compound{list: list})
    end
  end
end

defimpl MarkYamill.Decoder, for: Float do
  def decode(float) do
    float
  end
end

defimpl MarkYamill.Decoder, for: Integer do
  def decode(integer) do
    integer
  end
end

defimpl MarkYamill.Decoder, for: MarkYamill.Lists.Compound do
  alias MarkYamill.Decoder
  alias MarkYamill.Lists

  def decode(%Lists.Compound{list: list}) do
    processed = for i <- list, do: Decoder.decode(i)
    Decoder.decode(%Lists.Processed{list: processed})
  end
end

defimpl MarkYamill.Decoder, for: MarkYamill.Lists.Printable do
  alias MarkYamill.Lists.Printable

  def decode(%Printable{list: list}) do
    to_string(list)
  end
end

defimpl MarkYamill.Decoder, for: MarkYamill.Lists.Processed do
  alias MarkYamill.Lists.Processed

  def decode(%Processed{list: list}) do
    if map_list?(list) do
      Enum.into(list, %{})
    else
      list
    end
  end

  defp map_list?(list) do
    processed =
      list
      |> Enum.map(fn i -> key_value_pair?(i) end)
      |> Enum.uniq
    processed == [true]
  end

  defp key_value_pair?(term) do
    case term do
      {_, _} -> true
      _      -> false
    end
  end
end

defimpl MarkYamill.Decoder, for: Tuple do
  alias MarkYamill.Decoder

  def decode(tuple) do
    tuple
    |> Tuple.to_list()
    |> Enum.map(fn i -> Decoder.decode(i) end)
    |> List.to_tuple()
  end
end
