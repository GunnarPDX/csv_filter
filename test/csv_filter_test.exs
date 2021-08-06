defmodule CsvFilterTest do
  use ExUnit.Case
  #doctest CsvFilter

  test "runs with individual unique column" do
    result = CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["Email"])

    check_results(result, 22)
  end

  test "runs with non-existant individual unique column" do
    result = CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["ABC"])

    check_results(result, 33)
  end

  test "runs with multiple unique columns" do
    result = CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["Email", "Phone"])

    check_results(result, 18)
  end
  test "runs with multiple unique columns with some non-existant" do
    result = CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["Email", "Phone", "ABC", "123"])

    check_results(result, 18)
  end

  test "runs with unique column-set" do
    result = CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: [["Email", "Phone"]])

    check_results(result, 30)
  end

  test "runs with unique individual unique columns and column-set" do
    result = CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["Name", ["Email", "Phone"]])

    check_results(result, 12)
  end

  def check_results({status, table}, expected_count) do
    IO.inspect(table)
    row_count = Enum.count(table)
    assert row_count == expected_count
    assert status == :ok
  end

end
