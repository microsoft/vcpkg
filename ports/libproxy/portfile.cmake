# Enable static build in UNIX
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libproxy/libproxy
    REF e78a5ccfe0a2340f2c73e419767f8492ffc2787a #0.4.17
    SHA512 b22251f73f7a94dade5dcdcd9d5510170038b0d101ee98ab427106c20a3d9979c2b16c57d6cf8d8ae59c3a28ccffcecafc0bed399926dc2416a27837fd2f043c
    HEAD_REF master
    PATCHES
        fix-tools-path.patch
        support-windows.patch
        fix-dependency-libmodman.patch
        fix-install-py.patch
        fix-arm-build.patch
        fix-module-lib-name.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bindings-csharp WITH_DOTNET
        bindings-python WITH_PYTHON2
        bindings-python WITH_PYTHON3
        bindings-perl   WITH_PERL
        bindings-vala   WITH_VALA
        tools           BUILD_TOOLS
        tests           BUILD_TESTING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DWITH_WEBKIT3=OFF
    MAYBE_UNUSED_VARIABLES
        WITH_DOTNET
        WITH_PERL
        WITH_PYTHON2
        WITH_PYTHON3
        WITH_VALA
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/Modules)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
          "${CMAKE_CURRENT_LIST_DIR}/usage"
          DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
