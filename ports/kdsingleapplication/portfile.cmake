vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDSingleApplication
    REF "v${VERSION}"
    SHA512 7c8aa168a3183805f6fc5a4e5675527f9c14de0b7c0924333c8cc29b092000d35ed46044c4b8f4b2e68ee59e64fcb4ae04df83f4899ffa5128f8871eb3929a25
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
