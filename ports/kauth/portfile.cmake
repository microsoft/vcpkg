vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kauth
    REF "v${VERSION}"
    SHA512 9964dd191b069fb99111e5e2a30e57ecf1f464f5a0493e33fcf205a5b2abc91dfd8f834bb5993105192279327c01412c7066102d265df47ed20afa2d0dd79ddf
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        translations KF_SKIP_PO_PROCESSING
)

if(VCPKG_TARGET_IS_LINUX)
    list(APPEND FEATURE_OPTIONS -DKAUTH_BACKEND_NAME=PolkitQt6-1)
endif()

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
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
