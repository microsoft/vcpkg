# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xsimd
    REF 7.2.1
    SHA512 5b2bb403215cc621428957f6f8012c7e93d068152b8702a64803713b078767539c84c0dccb963e7002bbb3dc1aee887744d80014b01536becb49fe081eb882d4
    HEAD_REF master
)

if("xcomplex" IN_LIST FEATURES)
    set(ENABLE_XTL_COMPLEX ON)
else()
    set(ENABLE_XTL_COMPLEX OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_FALLBACK=OFF
        -DENABLE_XTL_COMPLEX=${ENABLE_XTL_COMPLEX}
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
