vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zyantific/zycore-c
    REF "v${VERSION}"
    SHA512 dd410010b99e11f40ad5234d21c9857bd57e47591ed9caec45c6199bfd690f7158499659c874680f2087bfd2b6eee41f08e95c367f83af3585690ce7d20ccb87
    HEAD_REF master
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
