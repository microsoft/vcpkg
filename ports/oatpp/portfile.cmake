set(OATPP_VERSION "1.3.0")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp
    REF "1.3.1"
    SHA512 2d6aec0a7f298fef19ce77517643388af4f127abe710b619aa17301b1c869b05f05758323370abdcc2eca9c675045f86b185af00b1689e469fc8aa4e02971f92
    HEAD_REF master
    PATCHES
        fix-target.patch
)

if (VCPKG_CRT_LINKAGE STREQUAL "static")
    set(OATPP_MSVC_LINK_STATIC_RUNTIME TRUE)
else()
    set(OATPP_MSVC_LINK_STATIC_RUNTIME FALSE)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"
        "-DOATPP_MSVC_LINK_STATIC_RUNTIME=${OATPP_MSVC_LINK_STATIC_RUNTIME}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME oatpp CONFIG_PATH lib/cmake/oatpp-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
