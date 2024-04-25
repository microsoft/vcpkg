vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rhash/RHash
    REF "v${VERSION}"
    SHA512 00a7e5e058b53ce20ae79509815452ed9cb699d1322b678220b72c61dea3ea2f8fa131acfade8bb6d9f6af913f0c3c472330841181b22314b8755166310c946f
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/librhash")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/librhash"
    OPTIONS
        -DRHASH_VERSION=${VERSION}
    OPTIONS_DEBUG
        -DRHASH_SKIP_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-rhash)
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/rhash.h" "# define RHASH_API" "# define RHASH_API __declspec(dllimport)")
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
