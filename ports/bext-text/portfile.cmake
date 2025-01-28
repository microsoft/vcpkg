vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tzlaine/text
    REF  dd2959e7143fde3f62b24d87a6573b5b96b6ea46
    SHA512 6897d6aac64f16ebf7c0fc4623d5b773844e6714d7c4feef69fad338657e7e7f845a0120b1ffb7b36e8b29f42afde470d0883e65bbcd7adb9466f07306ed64d5
    HEAD_REF master
    PATCHES fix-boost-dependency.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME text CONFIG_PATH "lib/cmake/text")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")

