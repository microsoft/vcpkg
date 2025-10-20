vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
  REPO lucocozz/Argus
  REF "v${VERSION}"
  SHA512 8464448d0aa664c8bf9f6992ee31db6827fd7b94c376446f4abe4ba8ff05ed85e86efc40fc9e9cbfb469a8fec5efaf2f8cb20cd28402a2091a614b157a63cf0b
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
