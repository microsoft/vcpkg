# cmake-scripts only
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/extra-cmake-modules
    REF "v${VERSION}"
    SHA512 1cf0785d61191305e62f3374a11f98de7bcceab5d03ee30ad178bb95c310c7f1ef86b9ba6f5c7f4de375000784b7981006361f4fa0c39436165dd45a6566e7d3
    HEAD_REF master
    PATCHES
        fix_generateqmltypes.patch # https://invent.kde.org/frameworks/extra-cmake-modules/-/merge_requests/201
        fix-wrong-version.patch
        # Adjust default installation dirs to vcpkg layout, reduce cross-platform variation
        uniform-dataroot-dir.patch
        uniform-libexec-dir.patch
        uniform-plugin-dir.patch
        # Avoid race while configuring downstream ports
        kde-clang-format.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_HTML_DOCS=OFF
        -DBUILD_MAN_DOCS=OFF
        -DBUILD_QTHELP_DOCS=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/ECM/cmake)

file(COPY "${CURRENT_PORT_DIR}/vcpkg-port-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING-CMAKE-SCRIPTS")
