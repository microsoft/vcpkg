vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kpackage
    REF "v${VERSION}"
    SHA512 1b58aa65a0040bcf0377b9355d81952e1fa6bd12d0f8d77492c240e1e76ea2882a9469bf1673e95cb2c8b66d5dc4690819b97629291d03f409aee4f3ef1d4f46
    HEAD_REF master
    PATCHES
        remove-stale-static-install.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        translations KF_SKIP_PO_PROCESSING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_KF6DocTools=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6package CONFIG_PATH lib/cmake/KF6Package)
vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES kpackagetool6 AUTO_CLEAN)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
# LICENSES/ lacks the text of the license of src/kpackage/private/utils.h
vcpkg_download_distfile(LGPL_2_1_LICENSE
    URLS "https://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt"
    FILENAME "kpackage-LGPL-2.1.txt"
    SHA512 e7e968ad0983d03f6bea8b35de580ce6d717fd4ade95e32ed26807d8ae89631c0f188a7a18f9eefba9a2eba46c31aa8b1f2aaa56621dea1df5140919b441ba39
)
list(APPEND LICENSE_FILES "${LGPL_2_1_LICENSE}")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
