if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # Unable to build shared library on Windows yet
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO minio/minio-cpp
    REF "v${VERSION}"
    SHA512 4ae6b3a3206b263f767a4c1461e07702eb66120e8a9f87c36bc7f0789538e8238cf0a1e8caf0a039e58bfb94ab782d642deacef84419bdad47496761a216c4b2
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME miniocpp CONFIG_PATH "lib/cmake/miniocpp")

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
