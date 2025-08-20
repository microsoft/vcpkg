vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BehaviorTree/BehaviorTree.CPP
    REF ${VERSION}
    SHA512 b2460f24915ab3aa803b95ca8a07a3d6d96c9e6d17f6b20297c45572162fe83f50e0cb51dd62da783ce6b962838bc0e74e7e137b8ef29a92f1805058beccc404
    HEAD_REF master
    PATCHES
        fix-x86_build.patch
        remove-source-charset.diff
        use-external-lexy.patch
        fix-dependencies.patch
)

# Set BTCPP_SHARED_LIBS based on VCPKG_LIBRARY_LINKAGE
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(BTCPP_SHARED_LIBS ON)
else()
    set(BTCPP_SHARED_LIBS OFF)
endif()

# Remove vendored lexy directory to prevent conflicts with foonathan-lexy port
file(REMOVE_RECURSE "${SOURCE_PATH}/3rdparty/lexy")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_ament_cmake=1
        -DCMAKE_DISABLE_FIND_PACKAGE_Curses=1
        -DBTCPP_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DBTCPP_BUILD_TOOLS=OFF
        -DBTCPP_GROOT_INTERFACE=OFF
        -DBTCPP_SQLITE_LOGGING=OFF
        -DBTCPP_SHARED_LIBS=${BTCPP_SHARED_LIBS}
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_Curses
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/behaviortree_cpp PACKAGE_NAME behaviortree_cpp)
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
