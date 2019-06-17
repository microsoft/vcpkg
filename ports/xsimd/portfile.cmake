# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xsimd
    REF 7.2.3
    SHA512 fb34eeb585f6820499734f10f03a4efd0d9a9b4be56f9bee21f3564eb92be56e7abe7682e476fafaff4733939f33f91cb4ab9209140b19f7b740538853433532
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
