vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sccn/liblsl
    REF v1.15.2 # NOTE: when updating version, also change it in the parameter to vcpkg_cmake_configure
    SHA512 77cfb4e546943554983cca2cdcf24dab267b0e0a9e5b5a82eeaf322ff943eeee8aeabbf134201c822c39c672c01596f7763c6d6d630f55ed249d5d4e72664bed
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LSL_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DLSL_BUILD_STATIC=${LSL_BUILD_STATIC}
        -DLSL_BUNDLED_PUGIXML=OFF # we use the pugixml vcpkg package instead
        -Dlslgitrevision=v1.15.2
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
