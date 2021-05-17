# static builds are currently not supported since liblsl always also builds shared binaries 
# which need to be deleted for vcpkg but then the CMake target can no longer be imported because it still references them
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sccn/liblsl
    REF v1.14.0 # NOTE: when updating version, also change it in the parameter to vcpkg_configure_cmake
    SHA512 b4ec379339d174c457c8c1ec69f9e51ea78a738e72ecc96b9193f07b5273acb296b5b1f90c9dfe16591ecab0eef9aae9add640c1936d3769cae0bd96617205ec
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLSL_BUILD_STATIC=OFF
        -DLSL_BUNDLED_PUGIXML=OFF # we use the pugixml vcpkg package instead
        -Dlslgitrevision=v1.14.0
        -Dlslgitbranch=master
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES lslver AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
