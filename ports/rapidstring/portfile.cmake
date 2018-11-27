include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boyerjohn/rapidstring
    REF ee433955c1e9cacfaecbf53c0a13318ab5825bd4
    SHA512 89e0656323d53dc3c47ba24ad9a032445b0985f21aaace05ea5bdbfb0ade5291193ac06145faf5984bcdff67c2a07a500109ce938174dbf1339fea2d79a6bd10
    HEAD_REF master
    PATCHES
        fix-cmake-install.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/rapidstring TARGET_PATH share/unofficial-rapidstring)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/rapidstring/copyright COPYONLY)
