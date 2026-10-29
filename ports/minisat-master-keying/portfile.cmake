vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(
    ADD_MISSING_HEADERS
    URLS https://github.com/master-keying/minisat/commit/dde8a20c9c5ab0d2333ba7a338a7f4a769632b75.patch?full_index=1
    SHA512 14b1ea9e72d969b0931a6ee571e4d7a591b6bdadd6b9c1e3696d902ab85caf22e0a65e4aadff3c16e55b2d5b04fa9f007bc015b6e914425c9932ca731f8445f2
    FILENAME dde8a20c9c5ab0d2333ba7a338a7f4a769632b75.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO master-keying/minisat
    REF v2.3.6
    SHA512 48E7AC1C97EA58070EAB9310F977404295E881B1403D527A33E059A0BB5A16CAA9AF2FA9E5230AD7E53E008B83077E300B3BAEEB0C220BE4E52B6B85887A05E1
    HEAD_REF master
    PATCHES
        "${ADD_MISSING_HEADERS}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME MiniSat CONFIG_PATH lib/cmake/MiniSat)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
