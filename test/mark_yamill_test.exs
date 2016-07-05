defmodule MarkYamillTest do
  use ExUnit.Case, async: true

  def decode do
    &MarkYamill.decode/1
  end

  def fetch!(file) do
    path = File.cwd! <> "/test/data/" <> file <> ".yml"
    File.read!(path)
  end

  def mapping_of_mappings do
    %{"Mark McGwire"=> %{"hr"=>65, "avg"=>0.278},
      "Sammy Sosa"=> %{"hr"=>63, "avg"=>0.288}}
  end

  def mapping_scalars_to_scalars do
    %{"hr" => 65, "avg" => 0.278, "rbi" => 147}
  end

  def mapping_scalars_to_sequencces do
    %{"american"=> ["Boston Red Sox", "Detroit Tigers", "New York Yankees"],
      "national"=> ["New York Mets", "Chicago Cubs", "Atlanta Braves"]}
  end

  def sequence_of_mappings do
    [%{"name"=> "Mark McGwire", "hr"=> 65, "avg"=> 0.278},
     %{"name"=> "Sammy Sosa", "hr"=> 63, "avg"=> 0.288}]
  end

  def sequence_of_sequences do
    [["name", "hr", "avg"],
     ["Mark McGwire", 65, 0.278],
     ["Sammy Sosa", 63, 0.288]]
  end

  def sequence_of_scalars do
    ["Mark McGwire", "Sammy Sosa", "Ken Griffey"]
  end

  test "pasring mapping_of_mappings" do
    yaml = fetch!("mapping_of_mappings")
    assert decode.(yaml) == mapping_of_mappings
  end

  test "pasring mapping_scalars_to_scalars" do
    yaml = fetch!("mapping_scalars_to_scalars")
    assert decode.(yaml) == mapping_scalars_to_scalars
  end

  test "pasring mapping_scalars_to_sequencces" do
    yaml = fetch!("mapping_scalars_to_sequencces")
    assert decode.(yaml) == mapping_scalars_to_sequencces
  end

  test "pasring sequence_of_scalars" do
    yaml = fetch!("sequence_of_scalars")
    assert decode.(yaml) == sequence_of_scalars
  end

  test "pasring sequence_of_mappings" do
    yaml = fetch!("sequence_of_mappings")
    assert decode.(yaml) == sequence_of_mappings
  end

  test "pasring sequence_of_sequences" do
    yaml = fetch!("sequence_of_sequences")
    assert decode.(yaml) == sequence_of_sequences
  end
end
