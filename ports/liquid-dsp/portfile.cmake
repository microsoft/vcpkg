vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jgaeddert/liquid-dsp
    REF "v${VERSION}"
    SHA512 d67a5dbbc4caf8027bfdc0616ddf6749d0ffe5356d60065cd8a7a8d77bd88461b844f0c94c1d800828063d90f819dca78f7141d675217743644c1365ccc99799
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
        -DENABLE_TIMESTAMPS=OFF
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
