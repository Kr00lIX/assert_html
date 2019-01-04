defmodule AssertHtml do
  @moduledoc """
  Documentation for AssertHtml.
  """
  alias AssertHtml.{Selector, Matcher, HTML}

  @type html :: String.t

  @typedoc """
  CSS selector
  """
  @type selector :: String.t
  @type response :: html | no_return()
  @type attributes :: []


  @type attribute_name :: String.t | atom()

  @type value :: String.t


  @spec html_selector(html, selector) :: html | nil
  def html_selector(html, selector) do
    Selector.find(html, selector)
  end

  @spec html_attribute(html, selector, attribute_name) :: value | nil
  def html_attribute(html, selector, name) do
    Selector.attribute(html, selector, name)
  end

  @spec html_attribute(html, attribute_name) :: value | nil
  def html_attribute(html, name) do
    Selector.attribute(html, name)
  end

  @spec html_text(html, selector) :: String.t | nil
  def html_text(html, selector) do
    Selector.html_text(html, selector)
  end

  @spec assert_html_selector(html, selector) :: response
  def assert_html_selector(html, selector) do
    Matcher.selector(:assert, html, selector)
    html
  end

  @spec assert_html_selector(html, selector) :: response
  def assert_html_selector(html, selector) do
    Matcher.selector(:assert, html, selector)
    html
  end

  @spec refute_html_selector(html, selector) :: response
  def refute_html_selector(html, selector) do
    Matcher.selector(:refute, html, selector)
    html
  end

  @spec assert_html_attributes(html, selector, attributes) :: response
  def assert_html_attributes(html, selector, attributes) do
    Matcher.assert_attributes(html, selector, attributes)
    html
  end

  @spec assert_html_text(html, selector, value) :: response
  def assert_html_text(html, selector, value) do
    Matcher.match_text(:assert,  selector, value)
    html
  end

  @spec assert_html_text(html, value) :: response
  def assert_html_text(html, value) do
    Matcher.match_text(:assert, html, value)
    html
  end

  @spec refute_html_text(html, selector, value) :: response
  def refute_html_text(html, selector, value) do
    Matcher.match_text(:refute,  selector, value)
    html
  end

  @spec refute_html_text(html, value) :: response
  def refute_html_text(html, value) do
    Matcher.match_text(:refute, html, value)
    html
  end

end
