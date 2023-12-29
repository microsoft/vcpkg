if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO charles-lunarg/vk-bootstrap
    REF "v${VERSION}"
    SHA512 c60567a5330908380efea8ac95036e63321fe1e2e72314068a5117c9c0f64cd8b80bd5e98eed9177f1f84dc4ee10a2a2dd902d111fc1a30f503287a7e4b22640
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVK_BOOTSTRAP_TEST=OFF
        -DVK_BOOTSTRAP_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
