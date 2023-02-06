defmodule Phosphoricons.Helpers do
  @doc "Removes the suffix type from an icon name"
  def remove_appendix(str) do
    str
    |> String.replace_suffix("_thin", "")
    |> String.replace_suffix("_light", "")
    |> String.replace_suffix("_bold", "")
    |> String.replace_suffix("_fill", "")
    |> String.replace_suffix("_duotone", "")
  end

  @doc "Converts opts to HTML attributes"
  def opts_to_attrs(opts) do
    for {key, value} <- opts do
      key =
        key
        |> Atom.to_string()
        |> String.replace("_", "-")
        |> Phoenix.HTML.Safe.to_iodata()

      value =
        if key == "class" do
          filter_class(value)
        else
          value
        end
        |> Phoenix.HTML.Safe.to_iodata()

      [?\s, key, ?=, ?", value, ?"]
    end
  end

  @doc "Inserts HTML attributes into an SVG icon"
  def insert_attrs(head, attrs, rest) do
    Phoenix.HTML.raw([head, attrs, rest])
  end

  def filter_class(value) when is_list(value), do: Enum.filter(value, & &1)
  def filter_class(value), do: value
end
