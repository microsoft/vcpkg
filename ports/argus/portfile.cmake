vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
  REPO lucocozz/Argus
  REF "v${VERSION}"
  SHA512 36b68a3f45722bdf1aff91e20661032e01cc37d38760a44133a8302869bce2fed9aa3dcb98bb8db7a1e09d5df5cf63f444182265ced49a4cb781f8adff9cb3f5
  HEAD_REF main
)

set(OPTIONS "")
if(NOT "regex" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dregex=false)
endif()
vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -Dbenchmarks=false
        -Dexamples=false
        -Dtests=false
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
