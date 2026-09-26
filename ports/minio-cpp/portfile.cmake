if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # Unable to build shared library on Windows yet
    if(NOT VCPKG_TARGET_IS_MINGW)
        # baseclient.cc exceeds the object section limit on ARM64 without /bigobj
        set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} /bigobj")
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO minio/minio-cpp
    REF "v${VERSION}"
    SHA512 3361e26bf63adb35b4fcf3a61f6abd58c064e41c0a5eb3e82cb2b33c75600c0ead27e29f5eccf013e5939964ee002da85a6b64732d33b7cf616fffebf0709809
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
