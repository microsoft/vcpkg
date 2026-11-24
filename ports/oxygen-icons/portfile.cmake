set(VCPKG_BUILD_TYPE release) # Only icons and data files

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/oxygen-icons
    REF "v${VERSION}"
    SHA512 830c5272c5d2747e2366d1f5e61742fa7eedfb66ec294e10903251b5bf55c860067cea844774675e75f1f7ced4cfa439f0b23c4aec4b03e9c53adca91110af37
    HEAD_REF master
    PATCHES
        optional-autotests.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" ${LICENSE_FILES})
