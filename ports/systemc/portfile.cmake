vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO accellera-official/systemc
    REF "${VERSION}"
    SHA512 baeadd0318b9ab47fc559a2ab6bd880ac506ac5d858cdcf081a7544ca01688f2e798549655ff7546d02feba120c084951f834b69678a0bb984299bff25a4e21b
    HEAD_REF main
    PATCHES
        install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=17
        -DDISABLE_COPYRIGHT_MESSAGE=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SystemCLanguage PACKAGE_NAME systemclanguage)
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/SystemCTLM PACKAGE_NAME systemctlm)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/sysc/packages/boost")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/sysc/packages/qt/time")

file(INSTALL "${SOURCE_PATH}/NOTICE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
