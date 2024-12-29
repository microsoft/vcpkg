vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BehaviorTree/BehaviorTree.CPP
    REF ${VERSION}
    SHA512 3dbe048b276dbb3c79f85bfae0ae5da4657088d08ef9b7b0674fac1fb4daf8fb3cf7e3ab774b71d363af6cd8ac7ed315b4dd6d3318a38aa0532e6e0d43e6fa37
    HEAD_REF master
    PATCHES
        fix-x86_build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_ament_cmake=1
        -DCMAKE_DISABLE_FIND_PACKAGE_Curses=1
        -DBTCPP_EXAMPLES=OFF
        -DBTCPP_UNIT_TESTS=OFF
        -DBTCPP_BUILD_TOOLS=OFF
        -DBTCPP_GROOT_INTERFACE=OFF
        -DBTCPP_SQLITE_LOGGING=OFF
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_Curses
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/behaviortree_cpp PACKAGE_NAME behaviortree_cpp)
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
