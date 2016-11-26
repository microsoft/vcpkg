include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/clockUtils-1.1.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ClockworkOrigins/clockUtils/archive/1.1.1.tar.gz"
    FILENAME "clockUtils-1.1.1.tar.gz"
    SHA512 6b0c57862baf04c0c5529549ba13983e53445172d9a272571aa20968ba6dba15f1cf480096ca100d450218fef090805366d0564c77a4aa4721a4fe694a0481c9
)
vcpkg_extract_source_archive(${ARCHIVE})

if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
    SET(SHARED_FLAG ON)
else()
    SET(SHARED_FLAG OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DWITH_LIBRARY_ARGPARSER=ON
        -DWITH_LIBRARY_COMPRESSION=ON
        -DWITH_LIBRARY_CONTAINER=ON
        -DWITH_LIBRARY_INIPARSER=ON
        -DWITH_LIBRARY_SOCKETS=ON
        -DWITH_TESTING=OFF
        -DCLOCKUTILS_BUILD_SHARED=${SHARED_FLAG}
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/clockUtils)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/clockUtils/LICENSE ${CURRENT_PACKAGES_DIR}/share/clockUtils/copyright)