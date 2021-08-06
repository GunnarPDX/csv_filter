defmodule CsvFilterTest do
  use ExUnit.Case
  #doctest CsvFilter

  test "runs with individual unique column" do
    assert CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["Email"]) == :ok
  end

  test "runs with non-existant individual unique column" do
    assert CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["ABC"]) == :ok
  end

  test "runs with multiple unique columns" do
    assert CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["Email", "Phone"]) == :ok
  end
  test "runs with multiple unique columns with some non-existant" do
    assert CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["Email", "Phone", "ABC", "123"]) == :ok
  end

  test "runs with unique column-set" do
    assert CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: [["Email", "Phone"]]) == :ok
  end

  test "runs with unique individual unique columns and column-set" do
    assert CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["Name", ["Email", "Phone"]]) == :ok
  end


end
