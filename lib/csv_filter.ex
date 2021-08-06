defmodule CsvFilter do
  @moduledoc """
  Documentation for `CsvFilter`.
  """

  @doc """
  Reduce CSV

  ## Examples
      iex> reduce_csv(file_path, output_file_path, unique: ["Email", "Phone"])
      :ok
  """
  # CsvFilter.reduce_csv("./test/data/users_sample.csv", "./test/data/output_sample.csv", unique: ["Email"])

  # %{
  #  "" => ["", "", "", ""],
  #  "Email" => "145@email.com",
  #  "Name" => "John Doe ",
  #  "Phone" => "5555555555"
  # }

  def reduce_csv(file_path, output_file_path, opts) when is_list(opts) do
    opts = Enum.into(opts, %{})

    output_file = File.open!(output_file_path, [:write, :utf8])

    updated_file =
      file_path
      |> File.stream!()
      |> CSV.decode(headers: true)
      |> Enum.each(fn x -> IO.inspect(x) end)

    :ok
  end
end
