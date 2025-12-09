string(REGEX REPLACE "(release-[0-9][.][0-9])[.]([0-9])\$" "\\1.0\\2" git_tag "release-${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BIC-MNI/libminc
    REF ${git_tag}
    SHA512 78d5c14b82c8da5de7651de22fe47ae934925b27a626b8685b19554b7a35240eb5ab6d4da6232ce046e9e0f25619bbfae1d7c0fc34994d935986dc151d7b93a0
    HEAD_REF master
    PATCHES
        avoid-try-run.diff
        build.patch
        cmake-config.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "minc1" LIBMINC_MINC1_SUPPORT
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # Symbols are not properly exported
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBMINC_BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DLIBMINC_BUILD_SHARED_LIBS=${LIBMINC_BUILD_SHARED_LIBS}
        -DLIBMINC_USE_SYSTEM_NIFTI=ON
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake PACKAGE_NAME libminc)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
