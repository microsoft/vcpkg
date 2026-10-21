vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO EsotericSoftware/spine-runtimes
    REF 43e530611d30c044a8bc16eba0486140e4dc2ce0
    SHA512 16a1ba493852c2512997bde4ab56318f435f65f23238544cf0c1000f53a2950cfd480255db6b3dc5c1d0b6a21a4be174be9401465d320b54c6b88c06e57e38d8
    HEAD_REF 4.2
    PATCHES
        fix-cmake.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/spine-cpp"
    OPTIONS
        -DSPINE_SET_COMPILER_FLAGS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
