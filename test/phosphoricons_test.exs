defmodule PhosphoriconsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  test "generated function" do
    zip_path =
      :code.priv_dir(:phosphoricons)
      |> Path.join("icons.zip")
      |> String.to_charlist()

    {:ok, [{_, alarm}]} =
      :zip.unzip(zip_path, [:memory, {:file_list, [~c"fill/alarm-fill.svg"]}])

    assert Phosphoricons.icon("alarm", type: "fill")
           |> Phoenix.HTML.safe_to_string() ==
             alarm

    assert Phosphoricons.icon("alarm", type: "fill", class: "h-6 w-6 text-gray-500")
           |> Phoenix.HTML.safe_to_string() =~
             ~s(class="h-6 w-6 text-gray-500")

    assert Phosphoricons.icon("alarm", type: "fill", class: ["h-6 w-6", "text-gray-500"])
           |> Phoenix.HTML.safe_to_string() =~
             ~s(class="h-6 w-6 text-gray-500")

    assert Phosphoricons.icon("alarm", type: "fill", class: "<> \" ")
           |> Phoenix.HTML.safe_to_string() =~
             ~s(class="&lt;&gt; &quot; ")

    assert Phosphoricons.icon("alarm", type: "fill", foo: "bar")
           |> Phoenix.HTML.safe_to_string() =~
             ~s(foo="bar")

    assert Phosphoricons.icon("alarm", type: "fill", multiword_key: "foo")
           |> Phoenix.HTML.safe_to_string() =~
             ~s(multiword-key="foo")

    assert Phosphoricons.icon("alarm", type: "fill", viewBox: "0 0 12 12")
           |> Phoenix.HTML.safe_to_string() =~
             ~s(viewBox="0 0 12 12")

    assert Phosphoricons.icon("alarm",
             type: "fill",
             class: "h-6 w-6 text-gray-500",
             phx_click: "update",
             phx_value_id: 5,
             alert: true
           )
           |> Phoenix.HTML.safe_to_string() =~
             ~s(phx-click="update" phx-value-id="5" alert="true")
  end

  test "generated components" do
    assert render_component(&Phosphoricons.LiveView.icon/1, assigns(name: "alarm")) =~
             ~s(<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 256 256\">)

    assert render_component(
             &Phosphoricons.LiveView.icon/1,
             assigns(name: "alarm", class: "h-6 w-6 text-gray-500")
           ) =~
             ~s(class="h-6 w-6 text-gray-500")

    assert render_component(
             &Phosphoricons.LiveView.icon/1,
             assigns(
               name: "alarm",
               opts: [phx_click: "update", phx_value_id: 5, alert: true]
             )
           ) =~
             ~s(phx-click="update" phx-value-id="5" alert="true")

    assert render_component(
             &Phosphoricons.LiveView.icon/1,
             assigns(
               name: "alarm",
               opts: [phx_click: "update", phx_value_element_id: 5, alert: true]
             )
           ) =~
             ~s(phx-click="update" phx-value-element_id="5" alert="true")
  end

  describe "icon/2 input handling" do
    test "defaults to regular weight when no type is given" do
      regular = Phosphoricons.icon("alarm") |> Phoenix.HTML.safe_to_string()
      explicit = Phosphoricons.icon("alarm", type: "regular") |> Phoenix.HTML.safe_to_string()
      assert regular == explicit
    end

    test "accepts atom name and atom type" do
      from_atoms = Phosphoricons.icon(:alarm, type: :fill) |> Phoenix.HTML.safe_to_string()
      from_strings = Phosphoricons.icon("alarm", type: "fill") |> Phoenix.HTML.safe_to_string()
      assert from_atoms == from_strings
    end

    test "name lookup is case-insensitive" do
      lower = Phosphoricons.icon("alarm", type: "fill") |> Phoenix.HTML.safe_to_string()
      upper = Phosphoricons.icon("ALARM", type: "FILL") |> Phoenix.HTML.safe_to_string()
      assert lower == upper
    end

    test "hyphenated icon names are accessed via underscores" do
      # priv/regular/address-book.svg should be reachable as "address_book"
      assert Phosphoricons.icon("address_book") |> Phoenix.HTML.safe_to_string() =~ ~s(<svg)
    end

    test "weight suffixes are stripped from the lookup key" do
      # priv/fill/alarm-fill.svg is keyed as "alarm" (not "alarm_fill") so the
      # caller never repeats the weight in the name.
      assert Phosphoricons.icon("alarm_fill", type: "fill") |> Phoenix.HTML.safe_to_string() =~
               "Icon alarm_fill (type fill) does not exist"
    end

    test "returns a friendly message for an unknown icon name" do
      rendered =
        Phosphoricons.icon("nope-not-real", type: "fill") |> Phoenix.HTML.safe_to_string()

      assert rendered == "Icon nope-not-real (type fill) does not exist"
    end

    test "returns a friendly message for an unknown type" do
      rendered =
        Phosphoricons.icon("alarm", type: "neon") |> Phoenix.HTML.safe_to_string()

      assert rendered == "Icon alarm (type neon) does not exist"
    end

    test "default_type/0 is regular" do
      assert Phosphoricons.default_type() == "regular"
    end
  end

  describe "rendering across all weights" do
    @weights ~w(thin light regular bold fill duotone)

    for weight <- @weights do
      test "renders alarm in #{weight} as a valid SVG element" do
        rendered =
          Phosphoricons.icon("alarm", type: unquote(weight))
          |> Phoenix.HTML.safe_to_string()

        assert String.starts_with?(rendered, "<svg")
        assert String.ends_with?(rendered, "</svg>")
        assert rendered =~ ~s(viewBox="0 0 256 256")
      end
    end

    test "stroke-bearing weights have their black stroke replaced with currentColor" do
      # Thin/light/regular/bold weights use stroke="#000" in source SVGs; the
      # compile-time loader rewrites them to currentColor so CSS color flows in.
      for weight <- ~w(thin light regular bold) do
        rendered =
          Phosphoricons.icon("alarm", type: weight)
          |> Phoenix.HTML.safe_to_string()

        assert rendered =~ ~s(stroke="currentColor"), "expected currentColor in #{weight}"
        refute rendered =~ ~s(stroke="#000"), "literal black stroke leaked into #{weight}"
      end
    end

    test "attributes are inserted into the opening <svg> tag, not after it" do
      rendered =
        Phosphoricons.icon("alarm", type: "fill", class: "h-4 w-4")
        |> Phoenix.HTML.safe_to_string()

      # Class must appear inside the first tag — i.e., before the first '>'.
      [first_tag, _rest] = String.split(rendered, ">", parts: 2)
      assert first_tag =~ ~s(class="h-4 w-4")
    end
  end

  describe "LiveView component" do
    test "passes a custom type through to the underlying icon" do
      rendered =
        render_component(&Phosphoricons.LiveView.icon/1, assigns(name: "alarm", type: "fill"))

      from_function = Phosphoricons.icon("alarm", type: "fill") |> Phoenix.HTML.safe_to_string()
      assert rendered =~ from_function
    end

    test "merges opts, type, and class together (class wins over a class in opts)" do
      rendered =
        render_component(
          &Phosphoricons.LiveView.icon/1,
          assigns(name: "alarm", class: "outer", opts: [class: "inner", data_test: "x"])
        )

      assert rendered =~ ~s(class="outer")
      refute rendered =~ ~s(class="inner")
      assert rendered =~ ~s(data-test="x")
    end

    test "renders the not-found message for an unknown icon" do
      rendered =
        render_component(&Phosphoricons.LiveView.icon/1, assigns(name: "definitely-not-here"))

      assert rendered =~ "does not exist"
    end
  end

  test "generated docs" do
    {:docs_v1, _annotation, _beam_language, _format, _module_doc, _metadata, docs} =
      Code.fetch_docs(Phosphoricons)

    doc =
      Enum.find_value(docs, fn
        {{:function, :icon, 2}, _annotation, _signature, doc, _metadata} -> doc
        _ -> nil
      end)

    assert doc["en"] == """
           ![](assets/Fill/alarm-fill.svg) {: width=24px}

           ## Examples

           Use as a `Phoenix.Component`

             <.icon name="alarm" />

             <.icon name="alarm" class="h-6 w-6 text-gray-500" />

           or as a function

             <%= icon("alarm") %>

             <%= icon("alarm", class: "h-6 w-6 text-gray-500") %>
           """
  end

  defp assigns(assigns) do
    Map.new(assigns)
    |> Map.put_new(:__changed__, %{})
  end
end
