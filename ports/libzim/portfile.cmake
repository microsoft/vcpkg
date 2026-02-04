vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openzim/libzim
    REF "${VERSION}"
    SHA512 acf11e4fe980adc1c0be760dab4d0f5a8d3da20579d918f627d439acc3266f12bae3f033c2f3f98009f6e1a20fc35190ca625b46fc581cb801594a8943e83d9d
    HEAD_REF main
    PATCHES
        cross-builds.diff
        dllexport.diff
        subdirs.diff
)

set(EXTRA_OPTIONS "")

if(NOT "xapian" IN_LIST FEATURES)
    list(APPEND EXTRA_OPTIONS "-Dwith_xapian=false")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -Dexamples=false
      ${EXTRA_OPTIONS}
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/zim/zim.h" "defined(LIBZIM_IMPORT_DLL)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
