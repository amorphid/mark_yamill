defmodule MarkYamill do
  alias MarkYamill.Decoder

  def decode(encoded) do
    encoded
    |> parse()
    |> Decoder.decode()
  end

  defp parse("---") do
    nil
  end

  defp parse(encoded) do
    case :yamerl_constr.string(encoded) do
      list when length(list) > 1 -> list
      list                       -> List.first(list)
    end
  end
end
