vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO strukturag/libde265
    REF v1.0.5
    SHA512 3ff7310fc4621cac0ef1cb9bbc4df61724f8943d57f5263a3663a77f4d90d84716b2a708ee9fec306e909dc8b5e7fe645a641b6a6db795a89a01799be910831e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libde265/)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
