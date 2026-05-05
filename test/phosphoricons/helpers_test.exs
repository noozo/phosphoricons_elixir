defmodule Phosphoricons.HelpersTest do
  use ExUnit.Case, async: true

  alias Phosphoricons.Helpers

  describe "remove_appendix/1" do
    test "strips each weight suffix" do
      assert Helpers.remove_appendix("alarm_thin") == "alarm"
      assert Helpers.remove_appendix("alarm_light") == "alarm"
      assert Helpers.remove_appendix("alarm_bold") == "alarm"
      assert Helpers.remove_appendix("alarm_fill") == "alarm"
      assert Helpers.remove_appendix("alarm_duotone") == "alarm"
    end

    test "regular weight files have no suffix and are returned as-is" do
      assert Helpers.remove_appendix("alarm") == "alarm"
    end

    test "strips every matching weight suffix in pipeline order" do
      # The implementation pipes through replace_suffix for each weight, so a
      # name with two stacked suffixes ends up stripped of both. This isn't a
      # case that occurs in real icon files, but documents current behavior.
      assert Helpers.remove_appendix("alarm_fill_bold") == "alarm"
    end

    test "leaves names that merely contain a weight word elsewhere" do
      assert Helpers.remove_appendix("thin_lines") == "thin_lines"
      assert Helpers.remove_appendix("bold_face") == "bold_face"
    end

    test "does not strip a non-suffix dash-style match" do
      assert Helpers.remove_appendix("alarm-fill") == "alarm-fill"
    end
  end

  describe "filter_class/1" do
    test "joins a list with spaces" do
      assert Helpers.filter_class(["h-6", "w-6", "text-gray-500"]) == "h-6 w-6 text-gray-500"
    end

    test "drops nil entries from a list" do
      assert Helpers.filter_class(["h-6", nil, "w-6"]) == "h-6 w-6"
    end

    test "drops false entries from a list (conditional class idiom)" do
      assert Helpers.filter_class(["h-6", false, "w-6"]) == "h-6 w-6"
    end

    test "passes a string through unchanged" do
      assert Helpers.filter_class("h-6 w-6") == "h-6 w-6"
    end

    test "an all-nil list collapses to empty string" do
      assert Helpers.filter_class([nil, nil]) == ""
    end
  end

  describe "opts_to_attrs/1" do
    test "converts underscored keys to dashed attribute names" do
      iodata = Helpers.opts_to_attrs(multiword_key: "foo")
      assert IO.iodata_to_binary(iodata) == ~s( multiword-key="foo")
    end

    test "preserves underscores after the phx-value- prefix" do
      iodata = Helpers.opts_to_attrs(phx_value_element_id: "abc")
      assert IO.iodata_to_binary(iodata) == ~s( phx-value-element_id="abc")
    end

    test "preserves camelCase keys with no underscore" do
      iodata = Helpers.opts_to_attrs(viewBox: "0 0 12 12")
      assert IO.iodata_to_binary(iodata) == ~s( viewBox="0 0 12 12")
    end

    test "escapes HTML-significant characters in values" do
      iodata = Helpers.opts_to_attrs(title: ~s(<script>"&))
      assert IO.iodata_to_binary(iodata) == ~s( title="&lt;script&gt;&quot;&amp;")
    end

    test "applies nil/false filtering only to the class attribute" do
      iodata = Helpers.opts_to_attrs(class: ["h-6", nil, false, "w-6"])
      assert IO.iodata_to_binary(iodata) == ~s( class="h-6 w-6")
    end

    test "non-class list values are passed straight to Phoenix.HTML.Safe and crash on nil" do
      # Documents that filter_class is class-only — other list-valued attrs
      # must not contain nil/false or Phoenix.HTML will raise.
      assert_raise ArgumentError, fn ->
        Helpers.opts_to_attrs(data: ["h-6", nil, "w-6"])
      end
    end

    test "renders non-string scalar values" do
      iodata = Helpers.opts_to_attrs(count: 5, alert: true)
      str = IO.iodata_to_binary(iodata)
      assert str =~ ~s(count="5")
      assert str =~ ~s(alert="true")
    end

    test "empty opts produces empty iodata" do
      assert Helpers.opts_to_attrs([]) == []
    end
  end
end
