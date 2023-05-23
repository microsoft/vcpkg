# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hpc-maths/samurai
    REF "v${VERSION}"
    SHA512 3eb7b09b94ce3736ba5f9a20979be585a638e9c3818649f12e0dadd6d0ebe4c477f8404649029a4f2ecf2376a839b2ab2f2b2441132b510a8f8002cb5d360857
    HEAD_REF master
    PATCHES
        0001-add-hdf5-dependency-in-cmake.patch
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_get_vars(cmake_vars_file)
include(${cmake_vars_file})

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -DFETCHCONTENT_FULLY_DISCONNECTED=OFF
            -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE="${SOURCE_PATH}/x64-windows-rel/_deps/_msvc_toolchain-src/Windows.MSVC.toolchain.cmake"
    )
else()
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -DFETCHCONTENT_FULLY_DISCONNECTED=OFF
    )
endif()

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
