vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsquish
    FILENAME "libsquish-1.15.tgz"
    NO_REMOVE_ONE_LEVEL
    SHA512 5b569b7023874c7a43063107e2e428ea19e6eb00de045a4a13fafe852ed5402093db4b65d540b5971ec2be0d21cb97dfad9161ebfe6cf6e5376174ff6c6c3e7a
    PATCHES
        fix-export-symbols.patch
        export-target.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sse2 BUILD_SQUISH_WITH_SSE2
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_SQUISH_WITH_OPENMP=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libsquish CONFIG_PATH share/unofficial-libsquish)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
