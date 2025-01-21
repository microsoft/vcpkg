if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO charles-lunarg/vk-bootstrap
    REF "v${VERSION}"
    SHA512 f925665b1d7a1c5069ca2cb6786f537bcc4b3060757db50d931091dc37ff4ef3b73b1b3adf0da84c256979fd780a2f6203de3299f634292600dcee925b9a5091
    HEAD_REF master
    PATCHES
        fix-targets.patch
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
