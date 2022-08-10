set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO tree-sitter/tree-sitter-cpp
  REF 818a564afc1571fc3996ddbe7227af778f7a112c
  SHA512 215d7af20a7f1ab95ea543353fd270abad4cd7c8560ace9b2c81da391e3da6ea27b11d700d47b06a02896c21ec05fe8ba13d89cc80dbe7260a69db5b8409f0c8
  HEAD_REF master
)

vcpkg_ts_parser_add(
  LANGUAGE cpp
  SOURCE_PATH "${SOURCE_PATH}"
  MIN_ABI_VERSION 13
)

