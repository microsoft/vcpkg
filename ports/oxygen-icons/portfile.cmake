set(VCPKG_BUILD_TYPE release) # Only icons and data files

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/oxygen-icons
    REF "v${VERSION}"
    SHA512 0db56dced7cb47c6f983bd5d97a3610ca54f78679f661f241e9128e3fe159fad8d71d69b4799040a91838ad702541d590ff77ade1e8635d6c81dba576ad2243c
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
