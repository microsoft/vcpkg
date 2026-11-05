vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openzim/libzim
    REF "${VERSION}"
    SHA512 16ea86511991be2f3c6deb47a96e6578c2f8117d1783508b6f10d89a42fa7ec19cf8dca6cde34f537a5b715240ec1a0ebee0d27081e3a2195c9ff8c59317639f
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
