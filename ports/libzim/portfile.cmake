vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openzim/libzim
    REF "${VERSION}"
    SHA512 0f365024c31ee350972292979f729a82181ea94c708fae31118b71efa03cbf462ad1b879d9e314c4f28819ff40d73c3808d30d91c10e2af0aa8a81686ff82770
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
