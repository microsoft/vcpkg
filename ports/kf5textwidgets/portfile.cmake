vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/ktextwidgets
    REF v5.73.0
    SHA512 47fb5a4294bbf8538b46bae5abead2e83e985d5ad8785f4152d1a796c5fde78015b39c9f2bf53a3f1d1c3e0ebacc380098a92abc9bcb7e834ff6af37bc4e2cd6
    HEAD_REF master
    PATCHES
        "add-missing-dependencies.patch"
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
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5TextWidgets)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
