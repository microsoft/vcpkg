vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/BehaviorTree/BehaviorTree.CPP/archive/${VERSION}.tar.gz"
    FILENAME "BehaviorTree.CPP.${VERSION}.tar.gz"
    SHA512 4505c4c8798ccbbc02f58320810eb86e791fb6ef57d8c85882e62bd2b509b41e0549dc311ed61926a873b5b956eda979efda488f01d00746e1e8db559f60253c
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
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
