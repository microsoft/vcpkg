vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/ktexttemplate
    REF "v${VERSION}"
    SHA512 c7296ea614ed61dd66b0a6fc0b5af104686dd3759064df48478147110b353d7def7396fb84b8f7ccca635ccf6bb86644cf1f890d983974c269512cb3cd475113
    HEAD_REF master
)
vcpkg_cmake_configure (
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGRANTLEE_BUILD_WITH_QT6=ON
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ktexttemplate)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
