defmodule CsvFilterTest do
  use ExUnit.Case
  #doctest CsvFilter

  test "runs with individual unique column" do
    result = CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["Email"])

    check_results(result, 22)
    check_unique_column(result, "Email")
  end

  test "runs with non-existant individual unique column" do
    result = CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["ABC"])

    check_results(result, 33)
  end

  test "runs with multiple unique columns" do
    result = CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["Email", "Phone"])

    check_results(result, 18)
    check_unique_column(result, "Email")
    check_unique_column(result, "Phone")
  end
  test "runs with multiple unique columns with some non-existant" do
    result = CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["Email", "Phone", "ABC", "123"])

    check_results(result, 18)
    check_unique_column(result, "Email")
    check_unique_column(result, "Phone")
  end

  test "runs with unique column-set" do
    result = CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: [["Email", "Phone"]])

    check_results(result, 30)
    check_unique_column_set(result, ["Email", "Phone"])
  end

  test "runs with unique individual unique columns and column-set" do
    result = CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["Name", ["Email", "Phone"]])

    check_results(result, 12)
    check_unique_column(result, "Name")
    check_unique_column_set(result, ["Email", "Phone"])
  end

  def check_results({status, table}, expected_count) do
    assert status == :ok

    row_count = Enum.count(table)
    assert row_count == expected_count
  end

  def check_unique_column({status, table}, unique_header) do
    row_count = Enum.count(table)
    row_count_check =
      table
      |> Enum.dedup_by(fn row -> row[unique_header] end)
      |> Enum.count()

    assert row_count == row_count_check
  end

  def check_unique_column_set({status, table}, unique_header_list) do

    row_count = Enum.count(table)
    row_count_check =
      table
      |> Enum.dedup_by(fn row -> Map.take(row, unique_header_list) end)
      |> Enum.count()

    assert row_count == row_count_check
  end

end
