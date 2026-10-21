vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rhash/RHash
    REF "v${VERSION}"
    SHA512 c125b71ec36cce2ec31057239cac8b987555f5e3b152dacb6386b905f8cc4d449c1de5b53e5a5206a2d87975681225c9b54e5826c10ffd91b3440f8595d22b15
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
