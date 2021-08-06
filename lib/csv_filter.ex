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
      :ok
  """
  # CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["Email"])

  def reduce_csv(file_path, output_file_path, opts) when is_list(opts) do
    opts = Enum.into(opts, %{})

    output_file = File.open!(output_file_path, [:write, :utf8])

    updated_file =
      file_path
      |> File.stream!()
      |> CSV.decode(headers: true)
      |> Stream.transform(nil, fn row, acc -> remove_duplicates(row, acc, opts) end)
      |> CSV.encode(headers: true)
      |> Enum.each(fn data -> IO.write(output_file, data) end)
    #|> Enum.each(fn x -> IO.inspect(x) end)

    :ok
  end

  # used inside Stream.transform/3
  # removes rows with duplicates from stream by returning the row or an empty enum
  # stores the previously scanned values in the accumulator (unique_store) for future reference
  defp remove_duplicates({:error, _}, unique_store, _), do: {[], unique_store}
  defp remove_duplicates({:ok, row}, nil, %{unique: headers}), do: {[row], map_headers(headers, row)}
  defp remove_duplicates({:ok, row}, unique_store, %{unique: headers}) do
    case Enum.reduce(headers, {true, unique_store}, fn header, acc -> check_unique_constraint(row, header, acc) end) do
      {true, updated_unique_store} -> {[row], updated_unique_store}
      {false, updated_unique_store} -> {[], updated_unique_store}
    end
  end

  # checks unique constraints when unique header set is passed in, ensure unique combination
  defp check_unique_constraint(row, header_set, {valid_row?, unique_store}) when is_list(header_set) do
    # loop through list of unique-header-maps and check for subset match to ensure no matches are found.
    unique? = Enum.any?(unique_store[header_set], fn value_map ->
      value_map
      |> Map.to_list()
      |> Enum.reject(fn {_k, v} -> v == [nil] end) # reject nil values from non-existent headers
      |> Enum.all?(fn v -> v in row end)
    end)

    updated_unique_store = update_unique_store(unique_store, header_set, row)

    # if cell is unique and the row is currently valid then return true
    cond do
      !unique? && valid_row? -> {true, updated_unique_store}
      true -> {false, updated_unique_store}
    end
  end

  # checks unique constraints when an individual header is passed in, insures column is unique
  defp check_unique_constraint(row, header, {valid_row?, unique_store}) do
    unique? = !Enum.any?(unique_store[header], fn value -> value == row[header] && value != nil end) # reject nil values from non-existent headers

    updated_unique_store = update_unique_store(unique_store, header, row)

    cond do
      unique? && valid_row? -> {true, updated_unique_store}
      true -> {false, updated_unique_store}
    end
  end

  # add new row values to unique_store
  defp update_unique_store(unique_store, header_set, row) when is_list(header_set),
       do: Map.update(unique_store, header_set, [], fn values -> values ++ [Map.take(row, header_set)] end)

  defp update_unique_store(unique_store, header, row),
       do: Map.update(unique_store, header, [], fn values -> values ++ [row[header]] end)

  # Recursively builds initial unique_store (accumulator) for remove_duplicates/3
  defp map_headers(headers, row) do
    Map.new(headers, fn header ->
      cond do
        is_list(header) -> {header, [map_headers(header, row)]}
        true -> {header, [row[header]]}
      end
    end)
  end

end
