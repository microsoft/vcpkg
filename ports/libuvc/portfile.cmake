vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libuvc/libuvc
    REF "v${VERSION}"
    SHA512 cf2c0a6cc04717f284f25bed17f178a4b2b2a2bb3e5937e50be144e88db2c481c5ea763c164fe0234834fea4837f96fcc13bdbdafd4610d2985943562dfcc72f
    HEAD_REF master
    PATCHES build_fix.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(BUILD_TARGET "Shared")
else()
    set(BUILD_TARGET "Static")
endif()

vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DPKG_CONFIG_EXECUTABLE="${PKGCONFIG}"
        -DCMAKE_BUILD_TARGET=${BUILD_TARGET}
        -DBUILD_EXAMPLE=OFF
        -DBUILD_TEST=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
