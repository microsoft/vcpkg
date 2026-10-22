vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fraunhoferhhi/vvdec
    REF v${VERSION}
    SHA512 35c9fa714530985cece58c76aa09a2e73abb192ae3bcb2780c0bd01baca3bddaeeda8e643c9c350ecd315b024f9322e4cedf9a05f4965172226d14aa513e2525
    HEAD_REF master
    PATCHES
        fix-dependency.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVVDEC_LIBRARY_ONLY=ON
        -DCCACHE_FOUND=OFF
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

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/vvdec/vvdecConfigVersion.cmake"
    [=[if( "${PACKAGE_FIND_VERSION_MAJOR}" EQUAL "3" )]=]
    [=[if( NOT PACKAGE_FIND_VERSION )
  set( PACKAGE_VERSION_COMPATIBLE TRUE )
elseif( "${PACKAGE_FIND_VERSION_MAJOR}" EQUAL "3" )]=]
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
