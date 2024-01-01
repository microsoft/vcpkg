vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fraunhoferhhi/vvenc
    REF v${VERSION}
    SHA512 bf2ac5fc3859cb3303ef4fa4fcdbe00a6db617e3c2e76c6d658071a7650e5966fa1522ccb2feca8c770cea3ea25d2b573dbd0c72f4c0d71be61ba7dd1ab9440b
    HEAD_REF master
    PATCHES
        fix-cmakelists.patch
        fix-dependencies.patch
        no-werror.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools  BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DCCACHE_FOUND=OFF
)


vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/vvenc)

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(BUILD_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES vvencFFapp vvencapp AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
