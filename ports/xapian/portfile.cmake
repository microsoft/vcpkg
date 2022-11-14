vcpkg_download_distfile(ARCHIVE
    URLS https://oligarchy.co.uk/xapian/1.4.21/xapian-core-1.4.21.tar.xz
    FILENAME xapian-core-1.4.21.tar.xz
    SHA512 4071791daf47f5ae77f32f358c6020fcfa9aa81c15c8da25489b055eef30383695e449ab1cb73670f2f5db2b2a5f78056da0e8eea89d83aaad91dfe340a6b13a
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

if(WIN32)
    vcpkg_replace_string("${SOURCE_PATH}/configure.ac" "z zlib zdll" "z zlib zdll zlibd")

    # xapian does not support debug lib on Windows
    # if use `set(VCPKG_BUILD_TYPE release)` ，the vcpkg post check can not passed，
    # it will throw exception "Mismatching number of debug and release binaries. Found 0 for debug but 1 for release."
    # that means the `set(VCPKG_BUILD_TYPE release)` can not be used in the WIN32 environment.
    if(VCPKG_BUILD_TYPE STREQUAL "release")
        set(OPTIONS "CXXFLAGS=-EHsc")
    endif()
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    USE_WRAPPERS
    OPTIONS ${OPTIONS}
)

vcpkg_install_make()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/xapian)

if (NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/xapian-config" "\"${CURRENT_INSTALLED_DIR}\"" "`dirname $0`/../../..")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/xapian-config" "\"${CURRENT_INSTALLED_DIR}/debug\"" "`dirname $0`/../../../../debug")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
