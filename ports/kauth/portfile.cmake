vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kauth
    REF "v${VERSION}"
    SHA512 c056a56de2b4019743a1b06ac9f1d647a6adb6750da8cc2912c8645635676089978b9c68f06cda485570bdca87bdcfac8c9ae88d70699f976f00d453e9269c92
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "${PORT} currently requires the following libraries from the system package manager:\n   libpolkit-qt6-1-dev\n\nThese can be installed on Ubuntu systems via apt-get install libpolkit-qt6-1-dev")
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        translations KF_SKIP_PO_PROCESSING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME kf6auth
    CONFIG_PATH lib/cmake/KF6Auth
)

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/kauth/kauth-policy-gen${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    vcpkg_copy_tools(
        TOOL_NAMES kauth/kauth-policy-gen
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/kauth"
        AUTO_CLEAN
    )
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/kauth")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/kauth")
    vcpkg_clean_executables_in_bin(FILE_NAMES none)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
