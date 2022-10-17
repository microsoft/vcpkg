set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO tree-sitter/tree-sitter-javascript
  REF 186f2adbf790552b354a9ba712341c7d48bdbccd
  SHA512 5c1a1c1d214e00935e839407d2e26e3994caf25dc0274c0313a398776022c511cbf7ae9e66e8c2a65c98b053d18db99edc6b286fa1b4cb74e53c44bb5d3b1b8a
  HEAD_REF master
)

vcpkg_add_ts_parser(
  LANGUAGE javascript
  SOURCE_PATH "${SOURCE_PATH}"
  MIN_ABI_VERSION 13
)

