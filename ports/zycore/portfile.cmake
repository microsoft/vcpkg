vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zyantific/zycore-c
    REF 4a8b5e2ab4d6ee73aa92d04bc318fed607394e67
    SHA512 c707f5e07411d9f00fa59e3c382345009f225ed9406063b9863604f15a9c45c9a32bc9c3100f08d9c5800cc2254f71bfae817979b85bc604739ca1ee854c94e5
    HEAD_REF master
    PATCHES
        fix-install.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" dynamic ZYCORE_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DZYCORE_BUILD_SHARED_LIB=${ZYCORE_BUILD_SHARED}
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/zycore
)
    
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
