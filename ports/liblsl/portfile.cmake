vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sccn/liblsl
    REF v${VERSION}
    SHA512 5b540c9b7c0b6fb5827dbb8afdc85267d8e36e3b807704af11ed89865754f1d786f28414adf1c3c7df15956143a0bfc82c449c5ff8656d18f1a6e03c4c1e89ce
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
        -DLSL_BUNDLED_PUGIXML=OFF # we use the pugixml vcpkg package instead
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
