vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rwfpl/rewolf-wow64ext
    REF "v${VERSION}"
    SHA512 bbd96200bb7ba581ce58c3935dff8f1cf336b58f88139ba53511fc9f9f3c98fc030db93b0586011a8afeb07a87b719a15498db2696c567beb4c6b55009c77e47
    HEAD_REF main
    PATCHES
        add-cmake.patch
        add-cmakelists.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/wow64ext" PACKAGE_NAME "wow64ext")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/lgpl-3.0.txt")
