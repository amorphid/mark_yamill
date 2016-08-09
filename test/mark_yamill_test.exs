defmodule MarkYamillTest do
  use ExUnit.Case, async: true

  def decode_file(file) do
    path = File.cwd! <> "/test/data/" <> file <> ".yml"
    MarkYamill.decode_file(path)
  end

  test "empty list" do
    actual   = decode_file("empty_list")
    expected = []
    assert actual == expected
  end

  describe "Given 'yamerl' fails to decode \"---\", then" do
    test "it should timeout" do
      task = Task.async(fn -> :yamerl_constr.string("---") end)
      assert catch_exit(Task.await(task, 100))
    end

    test "MarkYamill should handle this special case" do
      actual   = MarkYamill.decode("---")
      expected = nil
      assert actual == expected
    end
  end

  describe "From http://www.yaml.org/spec/1.2/spec.html, parsing Example" do
    test "2.1.  Sequence of Scalars (ball players)" do
      actual = decode_file("2.1")
      expected = ["Mark McGwire", "Sammy Sosa", "Ken Griffey"]
      assert actual == expected
    end

    test "2.2.  Mapping Scalars to Scalars (player statistics)" do
      actual = decode_file("2.2")
      expected = %{"hr"=>65, "avg"=>0.278, "rbi"=>147}
      assert actual == expected
    end

    test "2.3.  Mapping Scalars to Sequences (ball clubs in each league)" do
      actual = decode_file("2.3")
      expected =
        %{"american"=>["Boston Red Sox", "Detroit Tigers", "New York Yankees"],
          "national"=>["New York Mets", "Chicago Cubs", "Atlanta Braves"]}
      assert actual == expected
    end

    test "2.4.  Sequence of Mappings (players' statistics)" do
      actual = decode_file("2.4")
      expected =
        [%{"name"=>"Mark McGwire", "hr"=>65, "avg"=>0.278},
         %{"name"=>"Sammy Sosa", "hr"=>63, "avg"=>0.288}]
      assert actual == expected
    end

    test "2.5.  Sequence of Sequences" do
      actual = decode_file("2.5")
      expected =
        [["name", "hr", "avg"],
         ["Mark McGwire", 65, 0.278],
         ["Sammy Sosa", 63, 0.288]]
      assert actual == expected
    end

    test "2.6.  Mapping of Mappings" do
      actual = decode_file("2.6")
      expected =
        %{"Mark McGwire"=>%{"hr"=>65, "avg"=>0.278},
          "Sammy Sosa"=>%{"hr"=>63, "avg"=>0.288}}
      assert actual == expected
    end

    test "2.7.  Two Documents in a Stream (each with a leading comment)" do
      actual = decode_file("2.7")
      expected =
        [["Mark McGwire", "Sammy Sosa", "Ken Griffey"],
         ["Chicago Cubs", "St Louis Cardinals"]]
      assert actual == expected
    end

    test "2.8.  Play by Play Feed from a Game" do
      actual = decode_file("2.8")
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
      actual = decode_file("2.9")
      expected =
        %{"hr"=>["Mark McGwire", "Sammy Sosa"],
          "rbi"=>["Sammy Sosa", "Ken Griffey"]}
      assert actual == expected
    end

    test "2.10.  Node for 'Sammy Sosa' appears twice in this document" do
      actual = decode_file("2.10")
      expected =
        %{"hr"=>["Mark McGwire", "Sammy Sosa"],
          "rbi"=>["Sammy Sosa", "Ken Griffey"]}
      assert actual == expected
    end

    test "2.11.  Mapping between Sequences" do
      actual = decode_file("2.11")
      expected =
        %{["Detroit Tigers",
           "Chicago cubs"]=>["2001-07-23"],
          ["New York Yankees",
           "Atlanta Braves"]=>["2001-07-02", "2001-08-12", "2001-08-14"]}
      assert actual == expected
    end

    test "2.12.  Compact Nested Mapping" do
      actual = decode_file("2.12")
      expected =
        [%{"item"=>"Super Hoop", "quantity"=>1},
         %{"item"=>"Basketball", "quantity"=>4},
         %{"item"=>"Big Shoes", "quantity"=>1}]
      assert actual == expected
    end

    test "2.13.  In literals, newlines are preserved" do
      actual = decode_file("2.13")
      expected = "\\//||\\/||\n// ||  ||__\n"
      assert actual == expected
    end

    test "2.14.  In the folded scalars, newlines become spaces" do
      actual = decode_file("2.14")
      expected = "Mark McGwire's year was crippled by a knee injury.\n"
      assert actual == expected
    end

    test "2.15.  Folded newlines are preserved for 'more indented' and blank lines" do
      actual = decode_file("2.15")
      expected = "Sammy Sosa completed another fine season with great stats.\n\n  63 Home Runs\n  0.288 Batting Average\n\nWhat a year!\n"
      assert actual == expected
    end

    test "2.16.  Indentation determines scope" do
      actual = decode_file("2.16")
      expected =
        %{"name"=>"Mark McGwire",
          "accomplishment"=>"Mark set a major league home run record in 1998.\n",
          "stats"=>"65 Home Runs\n0.278 Batting Average\n"}
      assert actual == expected
    end

    test "2.17.  Quoted Scalars" do
      actual = decode_file("2.17")
      expected =
        %{"unicode"=>"Sosa did fine.☺",
          "control"=>"\b1998\t1999\t2000\n",
          "hex esc"=>"\r\n is \r\n",
          "single"=>"\"Howdy!\" he cried.",
          "quoted"=>" # Not a 'comment'.",
          "tie-fighter"=>"|\\-*-/|"}
      assert actual == expected
    end

    test "2.18.  Multi-line Flow Scalars" do
      actual = decode_file("2.18")
      expected =
        %{"plain"=>"This unquoted scalar spans many lines.",
          "quoted"=>"So does this quoted scalar.\n"}
      assert actual == expected
    end

    test "2.19.  Integers" do
      actual = decode_file("2.19")
      expected =
        %{"canonical"=>12345,
          "decimal"=>12345,
          "octal"=>12,
          "hexadecimal"=>12}
      assert actual == expected
    end

    test "2.20.  Floating Point" do
      actual = decode_file("2.20")
      expected =
        %{"canonical"=>1230.15,
          "exponential"=>1230.15,
          "fixed"=>1230.15,
          "negative infinity"=>:"-inf",
          "not a number"=>:nan}
      assert actual == expected
    end

    test "2.21.  Miscellaneous" do
      actual = decode_file("2.21")
      expected =
        %{nil=>nil,
          "booleans"=>[true, false],
          "string"=>"012345"}
      assert actual == expected
    end

    test "2.22.  Timestamps" do
      actual = decode_file("2.22")
      expected =
        %{"canonical"=>"2001-12-15T02:59:43.1Z",
          "iso8601"=>"2001-12-14t21:59:43.10-05:00",
          "spaced"=>"2001-12-14 21:59:43.10 -5",
          "date"=>"2002-12-14"}
      assert actual == expected
    end

    @doc """
    Because `binary` is an undefined tag, decoding `test/data/2.23-1.yml` will throw an error.
    """
    test "2.23-1.  Various Explicit Tags (w/ tags)" do
      assert catch_throw(decode_file("2.23-1"))
    end

    @doc """
    See `test/data/2.23-1.yml` for test w/ tags
    """
    test "2.23-2.  Various Explicit Tags (w/ tags removed)" do
      actual = decode_file("2.23-2")
      expected =
        %{"application specific tag"=>"The semantics of the tag\nabove may be different for\ndifferent documents.\n",
          "not-date"=>"2002-04-28",
          "picture"=>"R0lGODlhDAAMAIQAAP//9/X\n17unp5WZmZgAAAOfn515eXv\nPz7Y6OjuDg4J+fn5OTk6enp\n56enmleECcgggoBADs=\n"}
      assert actual == expected
    end

    @doc """
    Because `shape` is an undefined tag, decoding `test/data/2.24-1.yml` will throw an error.
    """
    test "2.24-1.  Global Tags (w/ tags)" do
      assert catch_throw(decode_file("2.24-1"))
    end

    @doc """
    See `test/data/2.24-1.yml` for test w/ tags
    """
    test "2.24-2.  Global Tags (w/ tags removed)" do
      actual = decode_file("2.24-2")
      expected =
        [%{"center"=>%{"x"=>73, "y"=>129}, "radius"=>7},
         %{"finish"=>%{"x"=>89, "y"=>102}, "start"=>"x"},
         %{"color"=>16772795, "start"=>"x", "text"=>"Pretty vector drawing."}]
      assert actual == expected
    end


    @doc """
    Because `set` is an undefined tag, decoding `test/data/2.25-1.yml` will throw an error.
    """
    test "2.25-1.  Unordered Sets (w/ tags)" do
      assert catch_throw(decode_file("2.25-1"))
    end

    @doc """
    See `test/data/2.25-1.yml` for test w/ tags
    """
    test "2.25-2.  Unordered Sets (w/ tags removed)" do
      actual = decode_file("2.25-2")
      expected =
        %{"Ken Griff"=>nil, "Mark McGwire"=>nil, "Sammy Sosa"=>nil}
      assert actual == expected
    end

    @doc """
    Because `omap` is an undefined tag, decoding `test/data/2.26-1.yml` will throw an error.
    """
    test "2.26-1.  Ordered Mappings (w/ tags removed)" do
      assert catch_throw(decode_file("2.26-1"))
    end

    @doc """
    See `test/data/2.26-1.yml` for test w/ tags
    """
    test "2.26-2.  Ordered Mappings (w/ tags removed)" do
      actual = decode_file("2.26-2")
      expected =
        [%{"Mark McGwire"=>65}, %{"Sammy Sosa"=>63}, %{"Ken Griffy"=>58}]
      assert actual == expected
    end

    @doc """
    Because `invoice` is an undefined tag, decoding `test/data/2.27-1.yml` will throw an error.
    """
    test "2.27-1.  Invoice (w/ tags)" do
      assert catch_throw(decode_file("2.27-1"))
    end

    @doc """
    See `test/data/2.27-1.yml` for test w/ tags
    """
    test "2.27-2.  Invoice (w/ tags removed)" do
      actual = decode_file("2.27-2")
      expected =
        %{"bill-to"=>%{"address"=>%{"city"=>"Royal Oak",
                                    "lines"=>"458 Walkman Dr.\nSuite #292\n", "postal"=>48046,
                                    "state"=>"MI"},
                       "family"=>"Dumars",
                       "given"=>"Chris"},
        "comments"=>"Late afternoon is best. Backup contact is Nancy Billsmer @ 338-4338.",
        "date"=>"2001-01-23",
        "invoice"=>34843,
        "product"=>[%{"description"=>"Basketball",
                      "price"=>450.0,
                      "quantity"=>4,
                      "sku"=>"BL394D"},
                    %{"description"=>"Super Hoop",
                      "price"=>2392.0,
                      "quantity"=>1,
                      "sku"=>"BL4438H"}],
        "ship-to"=>%{"address"=>%{"city"=>"Royal Oak",
                                  "lines"=>"458 Walkman Dr.\nSuite #292\n",
                                  "postal"=>48046,
                                  "state"=>"MI"},
                     "family"=>"Dumars",
                     "given"=>"Chris"},
        "tax"=>251.42,
        "total"=>4443.52}
      assert actual == expected
    end

    test "2.28.  Log File" do
      actual = decode_file("2.28")
      expected =
        [%{"Time"=>"2001-11-23 15:01:42 -5",
           "User"=>"ed",
           "Warning"=>"This is an error message for the log file"},
         %{"Time"=>"2001-11-23 15:02:31 -5",
           "User"=>"ed",
           "Warning"=>"A slightly different error message."},
         %{"Date"=>"2001-11-23 15:03:17 -5",
           "Fatal"=>"Unknown variable \"bar\"",
           "Stack"=>[%{"code"=>"x = MoreObject(\"345\\n\")\n",
                       "file"=>"TopClass.py",
                       "line"=>23},
                     %{"code"=>"foo = bar",
                       "file"=>"MoreClass.py",
                       "line"=>58}],
           "User"=>"ed"}]
      assert actual == expected
    end
  end
end
