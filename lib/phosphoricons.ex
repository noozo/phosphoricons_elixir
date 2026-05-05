defmodule Phosphoricons do
  @moduledoc """
  This library provides Phoenix Components for every [Phosphoricon](https://github.com/phosphor-icons/phosphor-home#phosphor-icons).
  It can be used with LiveView or Surface, as well as functions

  1047 icons and counting
  6 weights: Thin, Light, Regular, Bold, Fill, and Duotone
  Designed at 16 x 16px to read well small and scale up big
  Raw stroke information retained to fine-tune the style

  ## Examples
      <Phosphoricons.LiveView.Icon type="fill" name="flower" />

      <Phosphoricons.Surface.Icon type="thin" name="chat" class="w-6 h-6" />

  Can also be used as a function

      <%= Phosphoricons.icon("plus") %>

      <%= Phosphoricons.icon("x", class: "w-6 h-6") />

  Phosphoricons are designed by by [Tobias Fried](https://github.com/rektdeckard)
  """
  alias Phosphoricons.Helpers

  @icons_zip Path.join(:code.priv_dir(:phosphoricons), "icons.zip")
  @external_resource @icons_zip

  {:ok, zip_entries} = :zip.unzip(String.to_charlist(@icons_zip), [:memory])

  icons =
    zip_entries
    |> Enum.group_by(
      fn {path, _} -> path |> List.to_string() |> Path.split() |> hd() end,
      fn {path, contents} ->
        name =
          path
          |> List.to_string()
          |> Path.basename(".svg")
          |> String.replace("-", "_")
          |> Helpers.remove_appendix()

        icon = String.replace(contents, "stroke=\"#000\"", "stroke=\"currentColor\"")
        {i, _} = :binary.match(icon, ">")
        {name, String.split_at(icon, i)}
      end
    )
    |> Map.new(fn {weight, entries} -> {weight, Map.new(entries)} end)

  @icons icons

  @doc """
  ![](assets/Fill/alarm-fill.svg) {: width=24px}

  ## Examples

  Use as a `Phoenix.Component`

    <.icon name="alarm" />

    <.icon name="alarm" class="h-6 w-6 text-gray-500" />

  or as a function

    <%= icon("alarm") %>

    <%= icon("alarm", class: "h-6 w-6 text-gray-500") %>
  """
  def icon(name, opts \\ []) do
    {type, opts} = Keyword.pop(opts, :type, default_type())
    attrs = Helpers.opts_to_attrs(opts)
    name = maybe_convert_to_string(name)
    type = maybe_convert_to_string(type)

    @icons
    |> get_in([type, name])
    |> case do
      {head, rest} -> Helpers.insert_attrs(head, attrs, rest)
      _ -> Phoenix.HTML.raw(["Icon #{name} (type #{type}) does not exist"])
    end
  end

  def default_type, do: "regular"

  defp maybe_convert_to_string(value) when is_binary(value), do: String.downcase(value)

  defp maybe_convert_to_string(value) when is_atom(value),
    do: value |> Atom.to_string() |> String.downcase()
end
