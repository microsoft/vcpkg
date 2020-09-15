vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kwallet
    REF v5.73.0
    SHA512 2558336111969044232e3813eec68c71b0ab620883a283b032351be23d9269ad3782e52d25bedd04fe627fc7dfc8952ee4d260e66eda7cf26b2670bd42445441
    HEAD_REF master
)

vcpkg_find_acquire_program(GETTEXT_MSGMERGE)
get_filename_component(GETTEXT_MSGMERGE_EXE_PATH ${GETTEXT_MSGMERGE} DIRECTORY)
vcpkg_add_to_path(${GETTEXT_MSGMERGE_EXE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
            -DBUILD_KWALLETD=OFF
            -DBUILD_KWALLET_QUERY=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Wallet)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
