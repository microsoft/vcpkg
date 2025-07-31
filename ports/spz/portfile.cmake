if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nianticlabs/spz
    REF 9ba83ffedac9016bb76452598cb0dc676ad7e238 # switch to "v${VERSION}" with next release
    SHA512 6b68a5464b254c5e66ac2249df1b0a49196189c03e3d8da174dc09a5ecd47fc22142cb55e0d3530a79487ee1f708b69a751e7c3da6a9a76df785bb7935fed954
    HEAD_REF main
    PATCHES
        cmake-config.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/spz")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
