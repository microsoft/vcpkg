vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    #REPO sccn/liblsl
    #REF v1.15.2 # NOTE: when updating version, also change it in the parameter to vcpkg_cmake_configure
    REPO chausner/liblsl
    REF 79c0a38161e8669ef092cd5e48ba9bab17627a5e
    SHA512 0d7e2c6db63675f0b030e0d251229dd7f247258588cf8ec8f4cf51411ad5b6021d865047a69ba50c0a7693997f4225065841a17d75884ffe7f49d86035892cf1    
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LSL_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DLSL_BUILD_STATIC=${LSL_BUILD_STATIC}
        -DLSL_BUNDLED_BOOST=OFF # we use the boost vcpkg package instead
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
