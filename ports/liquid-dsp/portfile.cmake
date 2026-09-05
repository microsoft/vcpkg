vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jgaeddert/liquid-dsp
    REF "v${VERSION}"
    SHA512 83c55bf80bd61c1bca7c198e7ff8ce3dd06b2ff0ce27d7211e5437f17fe191bc742bd03c40f4a2c98f364dc6c28d39a89371cccb80624815cce0b23199aaddf0
    HEAD_REF master
    PATCHES
        fix-fftw3.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BUILD_SHARED_LIBS OFF)
    set(BUILD_STATIC_LIBS ON)
else()
    set(BUILD_SHARED_LIBS ON)
    set(BUILD_STATIC_LIBS OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_AUTOTESTS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_SANDBOX=OFF
        -DBUILD_DOC=OFF
        -DCOVERAGE=OFF
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
)

vcpkg_cmake_install()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/liquid-static)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/liquid)
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
