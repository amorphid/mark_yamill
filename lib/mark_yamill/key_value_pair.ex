defmodule MarkYamill.KeyValuePair do
  defstruct [:key, :value]

  def new({key, value}) do
    %__MODULE__{key: key, value: value}
  end
end
