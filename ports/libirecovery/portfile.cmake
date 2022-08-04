vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libirecovery
    REF 1.0.25
    SHA512 0dd91d4fe3ded2bc1bbd91aea964e31e7f59bce18be01aa096e974f37dc1be281644d6c44e3f9b49470dd961e3df2e3ff8a09bcc6b803a959073e7d7d9a8d3e7
    HEAD_REF msvc-master
)

vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH libirecovery.sln
    INCLUDES_SUBPATH include
    LICENSE_SUBPATH COPYING
    LANGUAGE C
    ADDITIONAL_LIBS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/getopt.lib"
    ADDITIONAL_LIBS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/getopt.lib"
)

file(REMOVE "${CURRENT_PACKAGES_DIR}/include/Makefile.am")
