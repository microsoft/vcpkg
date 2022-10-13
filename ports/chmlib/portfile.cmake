vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(CHMLIB_VERSION chmlib-0.40)
set(CHMLIB_FILENAME ${CHMLIB_VERSION}.zip)
set(CHMLIB_URL http://www.jedrea.com/chmlib/${CHMLIB_FILENAME})

vcpkg_download_distfile(
    ARCHIVE
    URLS ${CHMLIB_URL}
    FILENAME ${CHMLIB_FILENAME}
    SHA512 ad3b0d49fcf99e724c0c38b9c842bae9508d0e4ad47122b0f489c113160f5344223d311abb79f25cbb0b662bb00e2925d338d60dd20a0c309bda2822cda4cd24
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        all-platforms.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_RELEASE -DBUILD_TOOLS=ON
    OPTIONS_DEBUG -DBUILD_TOOLS=OFF
)

vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/src/chm_lib.h"  DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
