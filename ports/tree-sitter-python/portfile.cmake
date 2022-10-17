set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO tree-sitter/tree-sitter-python
  REF 188b6b062d8cb256e7dfe76b5ad5089bbdcb7014
  SHA512 b5dde8ba116453cdfd3b4f315a6d1d3120d05330c48ed5c78a2c28aa325b54f11f1bc275adaa7f78fb65e3328df35fc46d3597a0a39f5da68c4441994d2ea5d8
  HEAD_REF master
)

vcpkg_add_ts_parser(
  LANGUAGE python
  SOURCE_PATH "${SOURCE_PATH}"
  MIN_ABI_VERSION 13
)

