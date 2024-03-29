defmodule Phosphoricons.Helpers do
  @moduledoc """
    Helper module for Phosphoricons
  """

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
        |> convert_attr_key()
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

  defp convert_attr_key(key) do
    case key do
      # Exception for phx-value to keep variable names correct (i.e. opts={phx_value_element_id: ...})
      "phx_value_" <> event_key ->
        "phx-value-" <> event_key

      string_key ->
        String.replace(string_key, "_", "-")
    end
  end

  @doc "Inserts HTML attributes into an SVG icon"
  def insert_attrs(head, attrs, rest) do
    Phoenix.HTML.raw([head, attrs, rest])
  end

  def filter_class(value) when is_list(value), do: Enum.filter(value, & &1) |> Enum.join(" ")
  def filter_class(value), do: value
end
