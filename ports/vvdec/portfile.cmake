vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fraunhoferhhi/vvdec
    REF v${VERSION}
    SHA512 bb0085fbcd02fc22fe4e3a277907da8ca2b84b6e0769680a6792eb558fff62d1e7ae0a15a1377967562bb06513046e5eb38749dd08ee06f8badb5b8c246af17e
    HEAD_REF master
    PATCHES
        fix-dependency.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVVDEC_LIBRARY_ONLY=ON
        -DVVDEC_TOPLEVEL_OUTPUT_DIRS=OFF
        -DVVDEC_ENABLE_LINK_TIME_OPT=OFF
        -DVVDEC_ENABLE_WERROR=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/vvdec)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/vvdec/vvdecConfig.cmake"
    "# get current directory"
    "include(CMakeFindDependencyMacro)\nfind_dependency(Threads)\n\n# get current directory"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
