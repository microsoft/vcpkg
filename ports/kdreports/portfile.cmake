vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDReports
    REF "kdreports-${VERSION}"
    SHA512 f9b3785d71c68d032a0e1420ba3adae517994d257a02df69aaffcff4a8909b24d081c91b4cc9e1cc00311768f92e63b9288a99cfaac8422ebd1cae7321b3edbb
    HEAD_REF master
    PATCHES
        "fix-cmake-config.patch"
        "fix-license-text.patch"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KDReports_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DKDReports_QT6=ON
        -DKDReports_STATIC=${KDReports_STATIC}
        -DKDReports_TESTS=OFF
        -DKDReports_EXAMPLES=OFF
        -DKDReports_DOCS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_KDChart-qt6=ON
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME KDReports-qt6 CONFIG_PATH lib/cmake/KDReports-qt6)

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
