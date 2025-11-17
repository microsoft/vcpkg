vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openzim/libzim
    REF "${VERSION}"
    SHA512 de1588addec8b2398912a99cc5b46c1fa156d1ce01d2db1544b40c966bf305d859a52b51b8532d74cdba3c4e3392a3f4be68f4e8ac93392c56c3a24fa6b135c8
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
