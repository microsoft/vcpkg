vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sccn/liblsl
    REF a9a06c78d4218b76e1c906c04452eec697f02f8e # NOTE: when updating version, also change it in the parameter to vcpkg_cmake_configure
    SHA512 b58665e836e6a1fc6b7669f7ba1208e14468b5f6b8ba3fdd06936cc47c8b32a027de49a4e252c8b6fabc13f846af30b7d209c6ba79842d165049f4baad7e4da9    
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
        -Dlslgitrevision=v1.15.2-a9a06c
        -Dlslgitbranch=master
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES lslver AUTO_CLEAN)
vcpkg_cmake_config_fixup(PACKAGE_NAME LSL CONFIG_PATH lib/cmake/LSL)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
