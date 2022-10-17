set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO tree-sitter/tree-sitter-typescript
  REF 082da44a5263599186dadafd2c974c19f3a73d28
  SHA512 e45c8a860f5dc9ee03580bfeaf20db3f2dfb8571cc22e2a31619630157ae2944a9bf3b956bfe07ad96ca56baf2fb024dd1f3508877c527eacbcd0d4befa88656
  HEAD_REF master
)

vcpkg_add_ts_parser(
  LANGUAGE typescript
  SOURCE_PATH "${SOURCE_PATH}/typescript"
  MIN_ABI_VERSION 13
  LICENSE_FILE "${SOURCE_PATH}/LICENSE"
)

