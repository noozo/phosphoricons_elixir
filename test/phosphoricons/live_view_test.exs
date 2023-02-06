defmodule Phosphoricons.LiveViewTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  test "Generated LiveView Components" do
    assert render_component(
             &Phosphoricons.LiveView.icon/1,
             assigns(name: "alarm", class: "h-6 w-6 text-gray-500")
           ) =~
             ~s(class="h-6 w-6 text-gray-500")

    assert render_component(
             &Phosphoricons.LiveView.icon/1,
             assigns(name: "alarm", class: [true && "h-6", false && "w-6"])
           ) =~
             ~s(class="h-6")
  end

  defp assigns(assgns) do
    Map.new(assgns)
    |> Map.put_new(:__changed__, %{})
  end
end
