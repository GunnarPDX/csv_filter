defmodule CsvFilter do
  @moduledoc """
  Documentation for `CsvFilter`.
  """

  @doc """
  Reduce CSV

  Opens csv file as a stream, reads it, removes duplicates, and writes to new file.

  Unique headers can be passed in as a key-value pair options argument, currently this function only supports the `:unique` option.

  Individual headers can be passed in to enforce unique columns.
      ex: unique: ["Email", "Phone"]

      this would make sure the "Email" and "Phone" columns contain all unique values.

  Sets of headers can be passed in as well to enforce unique combinations.
      ex: unique: ["Email", ["Phone", "Name"]]

      this would make sure that the "Email" column is unique, and also enforce that all "Name" and "Phone" pairs are unique combinations.

  Headers that are missing from the file will be ignored.

  ## Examples
      iex> reduce_csv(file_path, output_file_path, unique: ["Email", "Phone"])
      {
        :ok,
        [
         %{
           "" => ["", "", "", ""],
           "Email" => "123@email.com",
           "Name" => "John Doe 1",
           "Phone" => "5555555555"
         },
          ...
        ]
      }
  """
  def reduce_csv(file_path, output_file_path, opts) when is_list(opts) do
    opts = Enum.into(opts, %{})

    output_file = File.open!(output_file_path, [:write, :utf8])

    updated_content =
      file_path
      |> File.stream!()
      |> CSV.decode(headers: true)
      |> Enum.map(fn
        {:ok, row} -> row
        _ -> %{}
      end)
      |> filter_duplicates(opts)
      #|> IO.inspect()

    errors? =
      updated_content
      |> CSV.encode(headers: true)
      |> Enum.map(fn row -> IO.write(output_file, row) end)
      |> Enum.any?(fn res -> res != :ok end)

    cond do
      errors? -> {:error, "Something went wrong..."}
      true -> {:ok, Enum.into(updated_content, [])}
    end
  end

  defp filter_duplicates(table, %{unique: header_opts}) do
    required_fields =
      header_opts
      |> List.flatten()
      |> Enum.uniq()

    table = Enum.reject(table, fn row -> missing_required_fields?(row, required_fields) end)

    Enum.reduce(header_opts, table, fn h, acc -> dedupe(acc, h) end)
  end

  defp missing_required_fields?(row, required_fields) do
    Enum.any?(required_fields, fn f ->
      row_value = Map.get(row, f)
      row_value == nil || row_value == ""
    end)
  end

  def dedupe(table, unique_header_set) when is_list(unique_header_set) do
    Enum.dedup_by(table, fn row -> Map.take(row, unique_header_set) end)
  end

  def dedupe(table, unique_header) do
    Enum.dedup_by(table, fn row -> row[unique_header] end)
  end


end
