# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xsimd
    REF 7.1.3
    SHA512 9f0e2babee9a3a80e16440466277bd635a26197f80cdf806312f7e1cc616db59062887566d50b4cdebe3c3ba4d60155b477684177607428aee53e1d5a95de926
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
