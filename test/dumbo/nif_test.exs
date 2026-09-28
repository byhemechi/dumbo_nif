defmodule Dumbo.NifTest do
  use ExUnit.Case, async: true

  doctest Dumbo.Nif

  describe "decode_numeric_float/1" do
    test "decodes a decimal float" do
      assert {:ok, {685_230.15, 10}} = Dumbo.Nif.decode_numeric_float("685230.15;")
    end

    test "decodes a leading-dot float" do
      assert {:ok, {0.5, 3}} = Dumbo.Nif.decode_numeric_float(".5;")
    end

    test "decodes a negative float" do
      assert {:ok, {-42.0, 4}} = Dumbo.Nif.decode_numeric_float("-42;")
    end

    test "decodes exponent notation without a decimal point" do
      assert {:ok, {1.0e3, 4}} = Dumbo.Nif.decode_numeric_float("1e3;")
    end

    test "decodes an upper-case signed exponent" do
      assert {:ok, {1.0e25, 8}} = Dumbo.Nif.decode_numeric_float("1.0E+25;")
    end

    test "decodes a trailing-dot mantissa with an exponent" do
      assert {:ok, {1.0e3, 5}} = Dumbo.Nif.decode_numeric_float("1.e3;")
    end

    test "returns the position just past the terminating semicolon" do
      assert {:ok, {1.5, 4}} = Dumbo.Nif.decode_numeric_float(~s'1.5;s:3:"foo";')
    end

    test "rejects a byte outside the float token alphabet" do
      assert {:error, {:unexpected_sequence, %{position: 0, token: "I"}}} =
               Dumbo.Nif.decode_numeric_float("INF;")
    end

    test "rejects a malformed token" do
      assert {:error, {:unexpected_sequence, %{position: 0, token: "1.2.3"}}} =
               Dumbo.Nif.decode_numeric_float("1.2.3;")

      assert {:error, {:unexpected_sequence, %{position: 0, token: "+1"}}} =
               Dumbo.Nif.decode_numeric_float("+1;")

      assert {:error, {:unexpected_sequence, %{position: 0, token: "1e"}}} =
               Dumbo.Nif.decode_numeric_float("1e;")

      assert {:error, {:unexpected_sequence, %{position: 0, token: "-"}}} =
               Dumbo.Nif.decode_numeric_float("-;")
    end

    test "rejects an empty token" do
      assert {:error, {:unexpected_sequence, %{position: 0, token: ""}}} =
               Dumbo.Nif.decode_numeric_float(";")
    end

    test "rejects an unterminated token" do
      assert {:error, {:unexpected_end, %{position: 3}}} = Dumbo.Nif.decode_numeric_float("1.5")
    end

    test "matches Dumbo.Decoder on accepted tokens" do
      for token <- [
            "0",
            "-0",
            "42",
            "-42",
            "685230.15",
            ".5",
            "-.5",
            "1.",
            "1.0",
            "1e3",
            "1E3",
            "1e+3",
            "1e-3",
            "1.e3",
            ".5e1",
            "1.0E+25",
            "3.141592653589793"
          ] do
        source = token <> ";"
        assert {:ok, {value, position}} = Dumbo.Nif.decode_numeric_float(source)
        assert value == Dumbo.Decoder.decode("d:" <> source)
        assert position == byte_size(source)
      end
    end
  end
end
