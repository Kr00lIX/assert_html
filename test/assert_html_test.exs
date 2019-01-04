defmodule AssertHtmlTest do
  use ExUnit.Case
  doctest AssertHtml
  import AssertHtml

  test ".html_text/2" do
    html = ~S{
      <div class="container">
        <h1>Hello</h1>
        <p class="descripition">
          Paragraph          
        </p>        
      </div>      
    }

    assert html_text(html, "h1") == "Hello"
    assert html_text(html, ".container .descripition") == "Paragraph"
    assert html_text(html, ".descripition .invalid") == ""
    assert html_text(html, ".descripition form") == ""
  end

  # test ".assert_html/2" do

  # end

  # test ".refute_html/2" do

  # end

  # test ".assert_html_text/2" do
    
  # end

  # test ".refute_html_text/2" do
    
  # end

  # test ".html_exists?/2" do
    
  # end
  
  # test ".html_text?/2" do
    
  # end
  
end
