vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sccn/liblsl
    REF v${VERSION}
    SHA512 bbf19fa15e1286bc47a55ea883faa11187bf148284908e15bc30543b553de666702f41ae9e4606b77505c3facdd72483c01de7fc8e84ca5c04c43b3563177650
    HEAD_REF master
    PATCHES
        use-find-package-asio.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LSL_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLSL_BUILD_STATIC=${LSL_BUILD_STATIC}
        -DLSL_BUNDLED_BOOST=OFF # we use the boost vcpkg packages instead
        -DLSL_FETCH_PUGIXML=OFF # we use the pugixml vcpkg package instead
        -DLSL_FRAMEWORK=OFF
        -Dlslgitrevision=v${VERSION}
        -Dlslgitbranch=master
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES lslver AUTO_CLEAN)
vcpkg_cmake_config_fixup(PACKAGE_NAME LSL CONFIG_PATH lib/cmake/lsl)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
