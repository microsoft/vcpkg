set(OATPP_VERSION "1.3.0")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-swagger
    REF "${VERSION}"
    SHA512 ba4668e3cc90163219a29d61ef5fba2f3565d9f35c2d050723b00706f2ac5bb721d020f1a49a7c9025694ff7c93c3ff7e4318ef4be5bd1438c02a54df72ba1e3
    HEAD_REF master
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
vcpkg_cmake_config_fixup(PACKAGE_NAME oatpp-swagger CONFIG_PATH lib/cmake/oatpp-swagger-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
