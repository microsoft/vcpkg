vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kglobalaccel
    REF "v${VERSION}"
    SHA512 b562d818ffadf856ff0a1078c4f773d479e62d5574c0837f0e7642cbd31c15a7c36711ba5af48221ef85fa53617f467b0d7ef05a03a0b3849b191864af90d87d
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "${PORT} currently requires the following libraries from the system package manager:\n   libxcb-keysyms1-dev libxcb-xkb-dev libxcb-record0-dev\n\nThese can be installed on Ubuntu systems via apt-get install libxcb-keysyms1-dev libxcb-xkb-dev libxcb-record0-dev")
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
vcpkg_cmake_config_fixup(
    PACKAGE_NAME kf6globalaccel
    CONFIG_PATH lib/cmake/KF6GlobalAccel
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
