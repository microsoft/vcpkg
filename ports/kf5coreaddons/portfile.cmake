include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kcoreaddons
    REF v5.51.0
    SHA512 c1859caacdbf02f919be358c66c62e9cceb6e7bee659d0c3b9d0edd21505f298f635afb85a3236fc75698f2af18e8486d3b152ff740d9026429ffbe4010a158b
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5CoreAddons)
vcpkg_copy_pdbs()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/kf5coreaddons)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/desktoptojson.exe ${CURRENT_PACKAGES_DIR}/tools/kf5coreaddons/desktoptojson.exe)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/kf5coreaddons)

file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/desktoptojson.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/kf5coreaddons RENAME copyright)
