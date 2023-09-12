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
    ADDITIONAL_LIBS getopt.lib
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(COPY "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/Makefile.am)
