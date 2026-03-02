vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/libraries
    REF "v${VERSION}"
    SHA512 4783697ada2102082e37fbb581d75fc04f89c71228771927ce1f63bbe05b24d632e574dec1aeae5a9e027996e30962852615a3c60d566404da7ddfabde53f87c
    HEAD_REF main
    PATCHES
#        cross-build.patch
        devendoring.patch
        use-cxx-20.patch
)

file(WRITE "${SOURCE_PATH}/cmake/CPM.cmake" "# disabled by vcpkg")

# Replace CPM and download cpp-library directly to avoid issues with FETCHCONTENT_FULLY_DISCONNECTED
vcpkg_from_github(
    OUT_SOURCE_PATH PACKAGE_PROJECT_PATH
    REPO stlab/cpp-library
    REF "v5.2.0"
    SHA512 4ff589b4a80c63991f2e7ba18236315ee94929775aa5c6bbffb54f445d60f14c5949386b80f71ce3ed547644f557a5bc3ca317b939468e699294565f73f689d8
    HEAD_REF master
)
file(RENAME "${PACKAGE_PROJECT_PATH}" "${SOURCE_PATH}/cmake/cpp-library")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/stlab)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
