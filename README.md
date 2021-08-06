# CsvFilter

Opens csv file as a stream, reads it, removes duplicates, and writes to new file.

  Unique headers can be passed in as a key-value pair options argument, currently this function only supports the `:unique` option.

  Individual headers can be passed in to enforce unique columns.
  - ex: `unique: ["Email", "Phone"]`
  - this would make sure the "Email" and "Phone" columns contain all unique values.

  Sets of headers can be passed in as well to enforce unique combinations.
  - ex: unique: ["Email", ["Phone", "Name"]]
  - this would make sure that the "Email" column is unique, and also enforce that all "Name" and "Phone" pairs are unique combinations.

  Headers that are missing from the file will be ignored.

  ## Examples
  ```elixir
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
  ```


## Installation

This package can be included by adding `csv_filter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:csv_filter, github: "GunnarPDX/csv_filter", tag: "v0.1.0"}
  ]
end
```

