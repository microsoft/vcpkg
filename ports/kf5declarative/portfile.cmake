vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kdeclarative
    REF v5.75.0
    SHA512 858744ef97f0bf0f824cbec38b0f72b38ff3d7429e7e4c055fc6fe227d7374244fc3d0fef8d12e24dcfa04589c4da9210cedf44487ea60bc33eb2eb1f3534522
    HEAD_REF master
)

vcpkg_cmake_configure(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_QTPLUGINDIR=plugins
        -DKDE_INSTALL_DATAROOTDIR=data
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5Declarative)
vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_copy_tools(
        TOOL_NAMES kpackagelauncherqml
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/qml ${CURRENT_PACKAGES_DIR}/debug/qml )
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/qml ${CURRENT_PACKAGES_DIR}/qml )

file(INSTALL ${SOURCE_PATH}/LICENSES/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)