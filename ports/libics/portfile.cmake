vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO svi-opensource/libics
    REF "${VERSION}"
    SHA512 678038870fc6badfc68848e40c2157bdd0511c205c13760c530fe521bf20d7e75d2c25de1c9506c3d109b1b7678744d3183dcd83322d11d58f3dc74739192403
    HEAD_REF master
    PATCHES
        real16.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/GNU_LICENSE")
