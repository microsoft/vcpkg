set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO tree-sitter/tree-sitter-typescript
  REF c94f0d5c31944beecdd14b39e185f816e95dbe6d
  SHA512 d4f4845535df290c2c737b0f2cd2b686f724e4f9c02a1610946c903be8a23a8e6eb1770c3e94c57160eba9c9b11e9d6227b622f3c924896efd10b6baa6c57421
  HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${SOURCE_PATH}/typescript)

vcpkg_ts_parser_add(
  LANGUAGE typescript
  SOURCE_PATH "${SOURCE_PATH}/typescript"
  MIN_ABI_VERSION 13
)

