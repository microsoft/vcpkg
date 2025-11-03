vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BehaviorTree/BehaviorTree.CPP
    REF ${VERSION}
    SHA512 956664e829c0b6ab9a398de7b7b788eb6da269d91823615925b7d080a3ecc784c610a9328761e2fad00507328f55307a6e5e667a779fa025937e5d519a4f2396
    HEAD_REF master
    PATCHES
        fix-x86_build.patch
        remove-source-charset.diff
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
        -DUSE_VENDORED_FLATBUFFERS=OFF
        -DUSE_VENDORED_LEXY=OFF
        -DUSE_VENDORED_MINITRACE=OFF
        -DUSE_VENDORED_TINYXML2=OFF
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_Curses
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/behaviortree_cpp PACKAGE_NAME behaviortree_cpp)
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
