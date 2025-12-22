vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDSingleApplication
    REF "v${VERSION}"
    SHA512 2832f53b70258af1bfe9d66d67ab1c46be720ccab632d1b76353a171414cea00a03c576ad34eeefb2648330a311867f7fde7efb96b1f16159dc206f890bc1085
    HEAD_REF master
    PATCHES "fix-license-text.patch"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KDSingleApplication_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DKDSingleApplication_QT6=ON
        -DKDSingleApplication_STATIC=${KDSingleApplication_STATIC}
        -DKDSingleApplication_TESTS=OFF
        -DKDSingleApplication_EXAMPLES=OFF
        -DKDSingleApplication_DOCS=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME KDSingleApplication-qt6 CONFIG_PATH lib/cmake/KDSingleApplication-qt6)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.txt"
        "${SOURCE_PATH}/LICENSES/BSD-3-Clause.txt"
        "${SOURCE_PATH}/LICENSES/MIT.txt"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
