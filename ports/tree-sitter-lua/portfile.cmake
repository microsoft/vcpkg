set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO MunifTanjim/tree-sitter-lua
  REF 88ad75ba99ed61d67f9f8fbc076abe9464b38e96
  SHA512 c00fc949c2468e975dd88153f04f82e466ff12f4d0d706562e935e5b56f862b5c83fcbe4e97d4179d167ec82996018e3207be5e5df694c91ad48c8e93552c3ba
  HEAD_REF master
)

file(TOUCH "${SOURCE_PATH}/LICENSE") # currently missing from upstream

vcpkg_ts_parser_add(
  LANGUAGE lua
  SOURCE_PATH "${SOURCE_PATH}"
  MIN_ABI_VERSION 13
)

