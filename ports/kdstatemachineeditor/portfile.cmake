vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDStateMachineEditor
    REF v${VERSION}
    SHA512 dedd7166f434689cd5acf4ee3172169d3f77182269d3187f0a7a12966467dd5c7733e3ff64cd1fd03b0f3866c2aafa37cc3f2d7b8a3f4a5d8a7592da039de7af
    HEAD_REF master
    PATCHES
      qt6.9.patch # This is already upstream
      fix-missing-targets.diff
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" VCPKG_BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DKDSME_QT6=ON
        -DKDSME_INTERNAL_GRAPHVIZ=OFF
        -DKDSME_DOCS=OFF
        -DKDSME_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_SHARED_LIBS=${VCPKG_BUILD_SHARED_LIBS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME KDSME-qt6 CONFIG_PATH lib/cmake/KDSME-qt6)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.txt"
        "${SOURCE_PATH}/LICENSES/BSD-3-Clause.txt"
        "${SOURCE_PATH}/LICENSES/GPL-3.0-or-later.txt"
        "${SOURCE_PATH}/LICENSES/LicenseRef-CISST.txt"
        "${SOURCE_PATH}/LICENSES/LicenseRef-Qt-Commercial.txt"
        "${SOURCE_PATH}/LICENSES/GPL-3.0-only.txt"
        "${SOURCE_PATH}/LICENSES/LGPL-2.1-only.txt"
        "${SOURCE_PATH}/LICENSES/LicenseRef-KDAB-KDStateMachineEditor.txt"
        "${SOURCE_PATH}/LICENSES/MIT.txt"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
