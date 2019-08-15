include(vcpkg_common_functions)

if (NOT ((VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux") OR (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")))
    message(FATAL_ERROR "libuuid currently only supports unix platforms.")
endif()

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libuuid-1.0.3)
vcpkg_download_distfile(ARCHIVE
    URLS "http://sourceforge.net/projects/libuuid/files/libuuid-1.0.3.tar.gz"
    FILENAME libuuid-1.0.3.tar.gz
    SHA512 77488caccc66503f6f2ded7bdfc4d3bc2c20b24a8dc95b2051633c695e99ec27876ffbafe38269b939826e1fdb06eea328f07b796c9e0aaca12331a787175507
)

vcpkg_extract_source_archive(${ARCHIVE})

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
    ${CMAKE_CURRENT_LIST_DIR}/config.linux.h
    DESTINATION ${SOURCE_PATH}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(INSTALL
    ${SOURCE_PATH}/COPYING
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/libuuid RENAME copyright)

vcpkg_copy_pdbs()
