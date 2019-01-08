# Changelog

## Unreleased

## Fixed
- Checking attributes with non sting values
- Check no existing attributes `attribute_name: nil`

### Added
- Add `assert_html_contains(html, value)` and `refute_html_contains(html, value)` checkers


## v0.0.1

### Added
- Allow use Regexp for checking attribute value
- Add `assert_attributes(html, selector, [id: "name"], fn(sub_html)->   end)` callback with selected html
- Add `assert_attributes(html, selector, id: "name")` checker
- Add `assert_html_selector(html, css_selector)` and `refute_html_selector((html, css_selector, value)` checkers
- Add `assert_html_text(html, value)` and `assert_html_text(html, css_selector, value)` checkers
- Add `refute_html_text(html, value)` and `refute_html_text((html, css_selector, value)` checkers
- Add `html_selector(html, css_selector)` method
- Add `html_attribute(html, css_selector)` and `html_attribute(html, css_selector, name)`  methods
- Add `html_text(html, css_selector)` method
- Basic ExDoc configuration
- Markdown documentation (README, LICENSE, CHANGELOG)