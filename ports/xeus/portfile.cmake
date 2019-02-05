include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xeus
    REF 24ad09ef6cfa251b842462e2eb84cb00987b1327
    SHA512 59a3ec921f5ee8e5347630fb478fb06e20f61fa1bc3d1d833ba545c6d39e9b06de316bb6118c7b9bae2b337057f9d00b08da0b6aa5f37fd907e95ed90cb757c8
    HEAD_REF master
    PATCHES
        no-override-debug-flags.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
        -DXEUS_USE_SHARED_CRYPTOPP=OFF # `cryptopp` port currently only supports static linkage.
        -DDISABLE_ARCH_NATIVE=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# Install usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# CMake integration test
#vcpkg_test_cmake(PACKAGE_NAME ${PORT})
