set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO tree-sitter/tree-sitter-javascript
  REF 90e54fd058cf5412be73aa4061cd0ee0e7e9ccc6
  SHA512 3cea2cb052014d6570c7afe75bb8f966220df5a764d54a81d7ae6c0b7df2173528c0d70cc427147d790ef9c21bb53c847816d9dfcd1efb1149881f4795ffdf71
  HEAD_REF master
)

vcpkg_ts_parser_add(
  LANGUAGE javascript
  SOURCE_PATH "${SOURCE_PATH}"
  MIN_ABI_VERSION 13
)

