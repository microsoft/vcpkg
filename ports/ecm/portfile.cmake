# cmake-scripts only
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/extra-cmake-modules
    REF "v${VERSION}"
    SHA512 18fe780bf4a4942d218162d4449a36f882a7b65d9bb0a82c4e2163a8623b860c41cd891efea9d2705874625551db24a04a9c5fb1877fdd07da092d09de01bc9f
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
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSES/BSD-2-Clause.txt"
    "${SOURCE_PATH}/LICENSES/BSD-3-Clause.txt"
    "${SOURCE_PATH}/LICENSES/CC0-1.0.txt"
    "${SOURCE_PATH}/toolchain/generate-fastlane-metadata.py"
    "${SOURCE_PATH}/LICENSES/MIT.txt"
)
