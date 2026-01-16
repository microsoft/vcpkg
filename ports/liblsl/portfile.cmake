vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sccn/liblsl
    REF v${VERSION}
    SHA512 b50d2e276a6c824da5a19e517e3684b1f4c33fa31ed839772f33faa5756b19c934bc4f1587bb488819345549fa063533ad05d2ec41d2798f158150b4f4a48ff5
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
