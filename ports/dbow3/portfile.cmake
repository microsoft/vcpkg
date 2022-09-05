vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rmsalinas/DBow3
    REF master
    SHA512 16e6789b77e8b42428d156ae5efa667861fa8ef2e85b54e3dd1d28e6f8dc7d119e973234c77cac82e775080fb9c859640d04159659a7d63941325e13e40b2814
    PATCHES
      fix_cmake.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DUSE_OPENCV_CONTRIB=ON
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH cmake/DBow3)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
