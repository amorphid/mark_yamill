defmodule MarkYamillTest do
  use ExUnit.Case, async: true

  def decode do
    &MarkYamill.decode/1
  end

  def fetch!(file) do
    path = File.cwd! <> "/test/data/" <> file <> ".yml"
    File.read!(path)
  end

  def mapping_scalars_to_scalars do
    %{"hr" => 65, "avg" => 0.278, "rbi" => 147}
  end

  def sequence_of_scalars do
    ["Mark McGwire", "Sammy Sosa", "Ken Griffey"]
  end

  test "pasring sequence_of_scalars" do
    yaml = fetch!("sequence_of_scalars")
    assert decode.(yaml) == sequence_of_scalars
  end

  test "pasring mapping_scalars_to_scalars" do
    yaml = fetch!("mapping_scalars_to_scalars")
    assert decode.(yaml) == mapping_scalars_to_scalars
  end
end
