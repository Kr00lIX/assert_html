# Used by "mix format"
locals_without_parens = [
  assert_html: 1,
  assert_html: 2,
  assert_html: 3,
  assert_html: 4,
  refute_html: 1,
  refute_html: 2,
  refute_html: 3,
  refute_html: 4
]

[
  inputs: [
    "mix.exs",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  locals_without_parens: locals_without_parens,
  line_length: 120,
  export: [
    locals_without_parens: locals_without_parens
  ]
]
