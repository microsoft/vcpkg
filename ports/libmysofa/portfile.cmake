vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hoene/libmysofa
    REF "v${VERSION}"
    SHA512 83f9b592b92984108ae1c43257d569320bf1b2c7b919563be2b92b0ec5396a4b2b9ad8dca579a2ad224c560c055fba8e77ca65d222e1944618a2819a0a8aa63c
    HEAD_REF main
    PATCHES
        dependencies.diff
        fix-package-version.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/windows/third-party")

# default.sofa is a symlink to MIT_KEMAR_normal_pinna.sofa, 
# which can cause problems e.g. on Windows file systems.
file(REMOVE "${SOURCE_PATH}/share/default.sofa")
file(COPY_FILE "${SOURCE_PATH}/share/MIT_KEMAR_normal_pinna.sofa" "${SOURCE_PATH}/share/default.sofa")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_STATIC_LIBS=${BUILD_STATIC}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME mysofa CONFIG_PATH lib/cmake/mysofa)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/src/resampler/speex_resampler.c"
        "${SOURCE_PATH}/src/hrtf/kdtree.c"
)
