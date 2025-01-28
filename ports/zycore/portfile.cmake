vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zyantific/zycore-c
    REF "v${VERSION}"
    SHA512 f57af4e5c6f919299e673ff4afd19a7e3cc01acaf5cde73db47063eb30881487fa33d2fd5707a3e55a8cd8df4bb4b668bc7273b8b8b5eebea1e78c1c36f715b2
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
