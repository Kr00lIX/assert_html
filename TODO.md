# TODO

## Change syntax
```
 test "shows new page form", %{conn: conn} do
    conn_resp = get(conn, Routes.page_path(conn, :new))
    assert response = html_response(conn_resp, 200)

    response
    |> assert_html("title", "New page")
    |> assert_html("p.description", ~r{You can check text by regular expression})
    |> refute_html(".check .element .if_doesnt_exist")
    |> assert_html("form.new_page", action: Routes.page_path(conn, :create), method: "post") do
      assert_html(".control_group") do
        assert_html("label", class: "form-label", text: "Page name")
        assert_html("input", type: "text", class: "form-control", value: "", name: "page[name]")
      end
      assert_html("button", class: "form-button", text: "Submit")
    end
  end
```

```
 test "shows new page form", %{conn: conn} do
    conn_resp = get(conn, Routes.page_path(conn, :new))
    assert response = html_response(conn_resp, 200)

    assert_html(response) do
      assert_html("title", "New page")
      assert_html("p.description", ~r{You can check text by regular expression})
      refute_html(".check .element .if_doesnt_exist")
      assert_html("form.new_page", action: Routes.page_path(conn, :create), method: "post") do
        assert_html(".control_group") do
            assert_html("label", class: "form-label", text: "Page name")
            assert_html("input", type: "text", class: "form-control", value: "", name: "page[name]")
          end
          assert_html("button", class: "form-button", text: "Submit")
        end
      end
    end
  end
```
```
 test "shows new page form", %{conn: conn} do
    conn_resp = get(conn, Routes.page_path(conn, :new))
    assert response = html_response(conn_resp, 200)

    html(response) do
      assert html("title", "New page")
      assert html("p.description", ~r{You can check text by regular expression})
      refute html(".check .element .if_doesnt_exist")
      assert html("form.new_page", action: Routes.page_path(conn, :create), method: "post") do
        assert html(".control_group") do
            assert html("label", class: "form-label", text: "Page name")
            assert html("input", type: "text", class: "form-control", value: "", name: "page[name]")
          end
          assert html("button", class: "form-button", text: "Submit")
        end
      end
    end
  end
```



## What to do with quoted values?!
