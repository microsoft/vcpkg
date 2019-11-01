include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kplotting
    REF v5.64.0
    SHA512 831b26a5e85a8baa1d49405e1358c7cda62b0a643e85b9677e2ceee413938fd03b96ff2c060dc2e0fa012da0a45452f32b734633ec4c99eecbf9d6228ff722b4
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
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Plotting)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/plugins ${CURRENT_PACKAGES_DIR}/debug/plugins)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/plugins ${CURRENT_PACKAGES_DIR}/plugins)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/kf5plotting RENAME copyright)
