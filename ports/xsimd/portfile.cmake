# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xsimd
    REF 7.1.2
    SHA512 9479eb6188a68388d470e38ec7b08aaeeb03a1028a574258b52e1c39ce0b1b1aaf97a5cb898447f68c989badd23903ba7a059f5daf59160c660ba751d668c0eb
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
