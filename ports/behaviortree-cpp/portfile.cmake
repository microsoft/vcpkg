vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BehaviorTree/BehaviorTree.CPP
    REF ${VERSION}
    SHA512 f2ee647c734e39e50f92405c5dc9fd2876602ff074a86416959fbf6548e37130d35f312cafb084ca4a40da7ee81386502a75ad839ce99a2859c30ff187820fdf
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
