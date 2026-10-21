vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
  REPO lucocozz/Argus
  REF "v${VERSION}"
  SHA512 34857f90a38879e5df10c44df8fc1afac625e636bf1619fa91decb9ea030b255c8b922373ceb365236b1d76be491cf8be9f263ba8ea3eb78209586efd7030f75
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
