defmodule MarkYamill do
  alias MarkYamill.Decoder

  def decode(encoded) do
    encoded
    |> parse()
    |> Decoder.decode()
  end

  defp parse(encoded) do
    encoded
    |> :yamerl_the_fork_constr.string()
    |> List.first()
  end
end
