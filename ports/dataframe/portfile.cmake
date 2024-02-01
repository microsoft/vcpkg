vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hosseinmoein/DataFrame
    REF "${VERSION}"
    SHA512 84eb826496b0e0051819aab6e7948ca877690b2d9a440e22ccf976ec17b4a9a87e0930c13372d82aeb24299502174f58b5287aef53abf21bcc71e5d00cc9a9cd
    HEAD_REF master
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHMDF_TESTING:BOOL=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/DataFrame)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License")
