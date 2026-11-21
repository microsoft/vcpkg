vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fraunhoferhhi/vvdec
    REF v${VERSION}
    SHA512 234ef603f452e73b0ff34e697868e04601e47121d47dbd9989aac0c4f9d8f7eb1038206e1fce5612890ed98c7a2050124ed7a075dab52f451ceffdf73f915263
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
