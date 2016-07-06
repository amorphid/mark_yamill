defmodule MarkYamillTest do
  use ExUnit.Case, async: true

  def decode(file) do
    path = File.cwd! <> "/test/data/" <> file <> ".yml"
    yaml = File.read!(path)
    MarkYamill.decode(yaml)
  end

  describe "parsing" do
    test "compact_nested_mapping" do
      actual = decode("compact_nested_mapping")
      expected =
        [%{"item" => "Super Hoop", "quantity" => 1},
         %{"item" => "Basketball", "quantity" => 4},
         %{"item" => "Big Shoes", "quantity" => 1}]
      assert actual == expected
    end

    test "folded_new_lines_are_preserved_for_more_indented_and_blank_lines" do
      actual = decode("folded_new_lines_are_preserved_for_more_indented_and_blank_lines")
      expected = "Sammy Sosa completed another fine season with great stats.\n\n  63 Home Runs\n  0.288 Batting Average\n\nWhat a year!\n"
      assert actual == expected
    end

    test "in_literals_newlines_are_preserved" do
      actual = decode("in_literals_newlines_are_preserved")
      expected = "\\//||\\/||\n// ||  ||__\n"
      assert actual == expected
    end

    test "indentation_determines_scope" do
      actual = decode("indentation_determines_scope")
      expected =
        %{"name"=>"Mark McGwire",
          "accomplishment"=>"Mark set a major league home run record in 1998.\n",
          "stats"=>"65 Home Runs\n0.278 Batting Average\n"}
      assert actual == expected
    end

    test "in_the_folded_scalars_new_lines_become_spaces" do
      actual = decode("in_the_folded_scalars_new_lines_become_spaces")
      expected = "Mark McGwire's year was crippled by a knee injury.\n"
      assert actual == expected
    end

    test "mapping_between_sequences" do
      actual = decode("mapping_between_sequences")
      expected =
        %{["Detroit Tigers", "Chicago cubs"] => ["2001-07-23"],
          ["New York Yankees", "Atlanta Braves"] => ["2001-07-02", "2001-08-12", "2001-08-14"]}
      assert actual == expected
    end

    test "mapping_of_mappings" do
      actual = decode("mapping_of_mappings")
      expected =
        %{"Mark McGwire"=> %{"hr"=>65, "avg"=>0.278},
          "Sammy Sosa"=> %{"hr"=>63, "avg"=>0.288}}
      assert actual == expected
    end

    test "mapping_scalars_to_scalars" do
      actual = decode("mapping_scalars_to_scalars")
      expected = %{"hr" => 65, "avg" => 0.278, "rbi" => 147}
      assert actual == expected
    end

    test "mapping_scalars_to_sequencces" do
      actual = decode("mapping_scalars_to_sequencces")
      expected =
        %{"american"=> ["Boston Red Sox", "Detroit Tigers", "New York Yankees"],
          "national"=> ["New York Mets", "Chicago Cubs", "Atlanta Braves"]}
      assert actual == expected
    end

    test "multi_line_flow_scalars" do
      actual = decode("multi_line_flow_scalars")
      expected =
        %{"plain"=>"This unquoted scalar spans many lines.",
          "quoted"=>"So does this quoted scalar.\n"}
      assert actual == expected
    end

    test "node_for_sammy_sosa_appears_twice_in_this_document" do
      actual = decode("node_for_sammy_sosa_appears_twice_in_this_document")
      expected =
        %{"hr"=>["Mark McGwire", "Sammy Sosa"],
          "rbi"=>["Sammy Sosa", "Ken Griffey"]}
      assert actual == expected
    end

    test "play_by_play_feed_from_a_game" do
      actual = decode("play_by_play_feed_from_a_game")
      expected =
        [%{"time"=> "20:03:20", "player"=> "Sammy Sosa", "action"=> "strike (miss)"},
         %{"time"=> "20:03:47", "player"=> "Sammy Sosa", "action"=> "grand slam"}]
      assert actual == expected
    end

    test "quoted_scalars" do
      actual = decode("quoted_scalars")
      expected =
        %{"unicode"=>"Sosa did fine.☺",
          "control"=>"\b1998\t1999\t2000\n",
          "hex esc"=>"\r\n is \r\n",
          "single"=>"\"Howdy!\" he cried.",
          "quoted"=>" # Not a 'comment'.",
          "tie-fighter"=>"|\\-*-/|"}
      assert actual == expected
    end

    test "sequence_of_scalars" do
      actual = decode("sequence_of_scalars")
      expected = ["Mark McGwire", "Sammy Sosa", "Ken Griffey"]
      assert actual == expected
    end

    test "sequence_of_mappings" do
      actual = decode("sequence_of_mappings")
      expected =
        [%{"name"=> "Mark McGwire", "hr"=> 65, "avg"=> 0.278},
         %{"name"=> "Sammy Sosa", "hr"=> 63, "avg"=> 0.288}]
      assert actual == expected
    end

    test "sequence_of_sequences" do
      actual = decode("sequence_of_sequences")
      expected =
        [["name", "hr", "avg"],
         ["Mark McGwire", 65, 0.278],
         ["Sammy Sosa", 63, 0.288]]
      assert actual == expected
    end

    test "single_document_with_two_comments" do
      actual = decode("single_document_with_two_comments")
      expected =
        %{"hr"=>["Mark McGwire", "Sammy Sosa"],
          "rbi"=>["Sammy Sosa", "Ken Griffey"]}
      assert actual == expected
    end

    test "two_documents_in_a_stream" do
      actual = decode("two_documents_in_a_stream")
      expected =
        [["Mark McGwire", "Sammy Sosa", "Ken Griffey"],
         ["Chicago Cubs", "St Louis Cardinals"]]
      assert actual == expected
    end
  end
end
