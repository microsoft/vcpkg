vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDStateMachineEditor
    REF "v${VERSION}"
    SHA512 53ce4990ef1e2cddd35a2747564dea563f26946769a14a083990fc38448d62b33e47b755301a7f0076383817721bc9ca16b4afeee322b59cdef142d6feab920b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKDSME_INTERNAL_GRAPHVIZ=OFF
        -DKDSME_DOCS=OFF
        -DKDSME_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME KDSME-qt6 CONFIG_PATH lib/cmake/KDSME-qt6)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/share/doc"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

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
