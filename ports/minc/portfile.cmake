string(APPEND git_tag "release-" "${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BIC-MNI/libminc
    REF ${git_tag}
    SHA512 d44213a0525f34c60ef4bd93c5ff7dfc1b8a73eebed6a27492816c6a30f573f404c0bae1f6c054fedb60bb8401fe8e6b723238177e254376d4cef9f44d85a1da
    HEAD_REF master
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
