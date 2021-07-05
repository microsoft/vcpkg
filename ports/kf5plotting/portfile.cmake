vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kplotting
    REF v5.81.0
    SHA512 bdeb55a3949abfe9673f3b799ba157c27aade2860bfd5db4588dcedd580f4be5f452434a8c56af25bceec1391c05a9e0d522b398f38c3acf5a3bfdb8f5d7c77d
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
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

file(INSTALL ${SOURCE_PATH}/LICENSES/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
