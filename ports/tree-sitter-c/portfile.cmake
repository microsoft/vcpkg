set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO tree-sitter/tree-sitter-c
  REF 0720f9c2af2a97dcd0e9ed90324d1baba68b2849
  SHA512 f43585a1bec0a6e48bb9429d1aee2a96ecf669f0cdd65917ac2d1b1e2cf8c36ffeadc8a93c36bb75ebfe8ef12cd66cae00925a41c854390f73ae60059ba6ae20
  HEAD_REF master
)

vcpkg_add_ts_parser(
  LANGUAGE c
  SOURCE_PATH "${SOURCE_PATH}"
  MIN_ABI_VERSION 13
)

