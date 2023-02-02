message(WARNING "qtkeychain is a third-party extension to Qt and is not affiliated with The Qt Company")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO frankosterfeld/qtkeychain
    # 0.13.2 plus three commits, for a CMake export target fix
    REF cd4d73299b144d11c310f6ca9a6ab1ef50c45431
    SHA512 a1af668bec23df5d696ad49129ec2aa6d332f043b43bb9875c2b025007452571bfd9431fd37c72189e957329491c04703e8c6d1104c7a117ebf28cb91249b639
    HEAD_REF master
)

# Opportunity to build without dependency on qt5-tools/qt5-declarative
set(BUILD_TRANSLATIONS OFF)
if("translations" IN_LIST FEATURES)
    set(BUILD_TRANSLATIONS ON)
endif()

vcpkg_cmake_configure(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_WITH_QT6=OFF
        -DBUILD_TEST_APPLICATION=OFF
        -DBUILD_TRANSLATIONS=${BUILD_TRANSLATIONS}
)
vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Qt5Keychain PACKAGE_NAME Qt5Keychain)

# Remove unneeded dirs
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
