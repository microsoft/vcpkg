message(WARNING "qtkeychain is a third-party extension to Qt and is not affiliated with The Qt Company")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO frankosterfeld/qtkeychain
    REF "${VERSION}"
    SHA512 b1068ae513d5eab8f300186497ddcce4075e11a2a569deddbc949177efaa27970ed7bdce0b1aff61a021144540e942f60c9259b975601a92c60b8a742754624a
    HEAD_REF main
)

# Opportunity to build without dependency on qt5-tools/qt5-declarative
set(BUILD_TRANSLATIONS OFF)
if("translations" IN_LIST FEATURES)
    set(BUILD_TRANSLATIONS ON)
endif()

vcpkg_cmake_configure(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH "${SOURCE_PATH}"
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
