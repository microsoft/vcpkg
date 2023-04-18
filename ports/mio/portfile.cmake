# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mandreyel/mio
    REF 8b6b7d878c89e81614d05edca7936de41ccdd2da
    SHA512 444131d4839f2244dd88722f5bfad2cfa47336e2a4405518a2ff8f0d80f2755321d7d627f8d5b890864a5dc3f3f810a1c7dd6588ff3e9039a6ef7d010e0f2f06
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dmio.tests=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/mio)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
