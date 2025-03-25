vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CD3/libInterpolate
    REF ${VERSION}
    SHA512 6d53e1fb3af3067ddd13e491563e8da5af9756efba5a2def486f014c23969633ca73cf43dd2f93047716ebb6565f5e9911b6ab85abef2db3b9faefc26ab3aa59  
    HEAD_REF master
    PATCHES
        fix-version-detection.patch
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DlibInterpolate_VERSION=${VERSION}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libInterpolate)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)