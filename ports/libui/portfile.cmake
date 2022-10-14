if(VCPKG_TARGET_IS_MINGW)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO andlabs/libui
    REF 7138276ccfbde94873cb6e2db65642adcbd2ee19
    SHA512 3a9fb27d0c376479f58ba2fc5be3579efa5f462776a7e725313b92413ce78f3ca60897e63b580c419eeaee2cd2101de2be1ee5af80a547ef433c6284a3053d45
    HEAD_REF master
    PATCHES
        "001-fix-cmake.patch"
        "002-fix-macosx-build.patch"
        "003-fix-system-link.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libui PACKAGE_NAME unofficial-libui)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
