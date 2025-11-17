vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO index1207/netcpp
    REF "v${VERSION}"
    SHA512 5f0c7a9ad414b868c23cde4c16a605c2029631935b252b3faa4e485ec1efa3dbfe64fd0b068db8e018481b6ac83f819facc1db371470be42c6919fcf69005e17
    HEAD_REF release
)

set(options -DNETCPP_TEST=OFF)

vcpkg_find_acquire_program(PKGCONFIG)
list(APPEND options "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")

if ("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "dynamic")
    list(APPEND options -DNETCPP_BUILD_SHARED=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
    MAYBE_UNUSED_VARIABLES
        PKG_CONFIG_EXECUTABLE
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/netcpp PACKAGE_NAME netcpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
