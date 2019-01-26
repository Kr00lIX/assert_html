# Used by "mix format"
[
  inputs: [
    "mix.exs",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  line_length: 160,
  export: [
    locals_without_parens: [
      assert_html: 2,
      assert_html: 3,
      assert_html: 4,
      refute_html: 2,
      refute_html: 3,
      refute_html: 4
    ]
  ]
]
