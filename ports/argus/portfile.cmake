vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
  REPO lucocozz/Argus
  REF "v${VERSION}"
  SHA512 191166366a60eaadfdbe0143c33f83b63d46e13e5bbcf24c56033b763da62ad60017f65ccf72cfcfca9a5a5da900fff11248fff456020845f06bb4e247850def
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
