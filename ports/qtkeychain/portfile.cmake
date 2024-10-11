message(WARNING "qtkeychain is a third-party extension to Qt and is not affiliated with The Qt Company")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO frankosterfeld/qtkeychain
    REF "${VERSION}"
    SHA512 d1d87553db94bf54da1373016a847476e6cd608db6d427ed72532658e2272501daf45d7c9976efdde2f26ab3810ba9dbfec2518d46dee5a76ecaa369bfee2e4a
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
