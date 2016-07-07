defmodule MarkYamillTest do
  use ExUnit.Case, async: true

  def decode(file) do
    path = File.cwd! <> "/test/data/" <> file <> ".yml"
    yaml = File.read!(path)
    MarkYamill.decode(yaml)
  end

  describe "From http://www.yaml.org/spec/1.2/spec.html, parsing Example" do
    test "2.1.  Sequence of Scalars (ball players)" do
      actual = decode("2.1")
      expected = ["Mark McGwire", "Sammy Sosa", "Ken Griffey"]
      assert actual == expected
    end

    test "2.2.  Mapping Scalars to Scalars (player statistics)" do
      actual = decode("2.2")
      expected = %{"hr"=>65, "avg"=>0.278, "rbi"=>147}
      assert actual == expected
    end

    test "2.3.  Mapping Scalars to Sequences (ball clubs in each league)" do
      actual = decode("2.3")
      expected =
        %{"american"=>["Boston Red Sox", "Detroit Tigers", "New York Yankees"],
          "national"=>["New York Mets", "Chicago Cubs", "Atlanta Braves"]}
      assert actual == expected
    end

    test "2.4.  Sequence of Mappings (players' statistics)" do
      actual = decode("2.4")
      expected =
        [%{"name"=>"Mark McGwire", "hr"=>65, "avg"=>0.278},
         %{"name"=>"Sammy Sosa", "hr"=>63, "avg"=>0.288}]
      assert actual == expected
    end

    test "2.5. Sequence of Sequences" do
      actual = decode("2.5")
      expected =
        [["name", "hr", "avg"],
         ["Mark McGwire", 65, 0.278],
         ["Sammy Sosa", 63, 0.288]]
      assert actual == expected
    end

    test "2.6. Mapping of Mappings" do
      actual = decode("2.6")
      expected =
        %{"Mark McGwire"=>%{"hr"=>65, "avg"=>0.278},
          "Sammy Sosa"=>%{"hr"=>63, "avg"=>0.288}}
      assert actual == expected
    end

    test "2.7.  Two Documents in a Stream (each with a leading comment)" do
      actual = decode("2.7")
      expected =
        [["Mark McGwire", "Sammy Sosa", "Ken Griffey"],
         ["Chicago Cubs", "St Louis Cardinals"]]
      assert actual == expected
    end

    test "2.8.  Play by Play Feed from a Game" do
      actual = decode("2.8")
      expected =
        [%{"time"=>"20:03:20",
           "player"=>"Sammy Sosa",
           "action"=>"strike (miss)"},
         %{"time"=>"20:03:47",
           "player"=>"Sammy Sosa",
           "action"=>"grand slam"}]
      assert actual == expected
    end

    test "2.9.  Single Document with Two Comments" do
      actual = decode("2.9")
      expected =
        %{"hr"=>["Mark McGwire", "Sammy Sosa"],
          "rbi"=>["Sammy Sosa", "Ken Griffey"]}
      assert actual == expected
    end

    test "2.10.  Node for 'Sammy Sosa' appears twice in this document" do
      actual = decode("2.10")
      expected =
        %{"hr"=>["Mark McGwire", "Sammy Sosa"],
          "rbi"=>["Sammy Sosa", "Ken Griffey"]}
      assert actual == expected
    end

    test "2.11. Mapping between Sequences" do
      actual = decode("2.11")
      expected =
        %{["Detroit Tigers",
           "Chicago cubs"]=>["2001-07-23"],
          ["New York Yankees",
           "Atlanta Braves"]=>["2001-07-02", "2001-08-12", "2001-08-14"]}
      assert actual == expected
    end

    test "2.12. Compact Nested Mapping" do
      actual = decode("2.12")
      expected =
        [%{"item"=>"Super Hoop", "quantity"=>1},
         %{"item"=>"Basketball", "quantity"=>4},
         %{"item"=>"Big Shoes", "quantity"=>1}]
      assert actual == expected
    end

    test "2.13.  In literals, newlines are preserved" do
      actual = decode("2.13")
      expected = "\\//||\\/||\n// ||  ||__\n"
      assert actual == expected
    end

    test "2.14.  In the folded scalars, newlines become spaces" do
      actual = decode("2.14")
      expected = "Mark McGwire's year was crippled by a knee injury.\n"
      assert actual == expected
    end

    test "2.15.  Folded newlines are preserved for 'more indented' and blank lines" do
      actual = decode("2.15")
      expected = "Sammy Sosa completed another fine season with great stats.\n\n  63 Home Runs\n  0.288 Batting Average\n\nWhat a year!\n"
      assert actual == expected
    end

    test "2.16.  Indentation determines scope" do
      actual = decode("2.16")
      expected =
        %{"name"=>"Mark McGwire",
          "accomplishment"=>"Mark set a major league home run record in 1998.\n",
          "stats"=>"65 Home Runs\n0.278 Batting Average\n"}
      assert actual == expected
    end

    test "2.17. Quoted Scalars" do
      actual = decode("2.17")
      expected =
        %{"unicode"=>"Sosa did fine.☺",
          "control"=>"\b1998\t1999\t2000\n",
          "hex esc"=>"\r\n is \r\n",
          "single"=>"\"Howdy!\" he cried.",
          "quoted"=>" # Not a 'comment'.",
          "tie-fighter"=>"|\\-*-/|"}
      assert actual == expected
    end

    test "2.18. Multi-line Flow Scalars" do
      actual = decode("2.18")
      expected =
        %{"plain"=>"This unquoted scalar spans many lines.",
          "quoted"=>"So does this quoted scalar.\n"}
      assert actual == expected
    end

    test "2.19. Integers" do
      actual = decode("2.19")
      expected =
        %{"canonical"=>12345,
          "decimal"=>12345,
          "octal"=>12,
          "hexadecimal"=>12}
      assert actual == expected
    end

    test "2.20. Floating Point" do
      actual = decode("2.20")
      expected =
        %{"canonical"=>1230.15,
          "exponential"=>1230.15,
          "fixed"=>1230.15,
          "negative infinity"=>:"-inf",
          "not a number"=>:nan}
      assert actual == expected
    end

    test "2.21. Miscellaneous" do
      actual = decode("2.21")
      expected =
        %{nil=>nil,
          "booleans"=>[true, false],
          "string"=>"012345"}
      assert actual == expected
    end

    test "2.22. Miscellaneous" do
      actual = decode("2.22")
      expected =
        %{"canonical"=>"2001-12-15T02:59:43.1Z",
          "iso8601"=>"2001-12-14t21:59:43.10-05:00",
          "spaced"=>"2001-12-14 21:59:43.10 -5",
          "date"=>"2002-12-14"}
      assert actual == expected
    end

    @doc """
    Because `!!binary` is an undefined tags, decoding `test/data/2.23.yml` will throw an error.
    """
    test "2.23. Various Explicit Tags" do
      assert catch_throw(decode("2.23"))
    end

    @doc """
    Because `!binary` is an undefined tags, decoding `test/data/2.23.yml` will throw an error.
    """
    test "2.24. Miscellaneous" do
      assert catch_throw(decode("2.24"))
    end


    @doc """
    Because `!!set` is an undefined tags, decoding `test/data/2.23.yml` will throw an error.
    """
    test "2.25. Unordered Sets" do
      assert catch_throw(decode("2.25"))
    end

    @doc """
    Because `!!` is an undefined tags, decoding `test/data/2.23.yml` will throw an error.
    """
    test "2.26. Ordered Mappings" do
      assert catch_throw(decode("2.26"))
    end
  end
end
