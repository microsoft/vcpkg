vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BehaviorTree/BehaviorTree.CPP
    REF "${VERSION}"
    SHA512 23ac30d7824282f641372f709b6b7a800a2947113bbb09d599f68547a3a67f509992cd0ca251e86b101062fe0d6697373b6851d21e7648578aadf1aa924e7ccf
    HEAD_REF master
    PATCHES
        remove-source-charset.diff # because vcpkg's default toolchain uses /utf-8 which is incompatible with /source-charset
        fix-dependencies.patch
)

# Set BTCPP_SHARED_LIBS based on VCPKG_LIBRARY_LINKAGE
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BTCPP_SHARED_LIBS)

# Remove vendored lexy directory to prevent conflicts with foonathan-lexy port
file(REMOVE_RECURSE "${SOURCE_PATH}/3rdparty/lexy")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_ament_cmake=1
        -DBTCPP_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DBTCPP_BUILD_TOOLS=OFF
        -DBTCPP_GROOT_INTERFACE=OFF
        -DBTCPP_SQLITE_LOGGING=OFF
        -DBTCPP_SHARED_LIBS=${BTCPP_SHARED_LIBS}
        -DUSE_VENDORED_FLATBUFFERS=OFF
        -DUSE_VENDORED_MINITRACE=OFF
        -DUSE_VENDORED_TINYXML2=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/behaviortree_cpp PACKAGE_NAME behaviortree_cpp)
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
