vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kparts
    REF v5.73.0
    SHA512 8076a1d9390fc588369c3e5c416d42dea11dfa6e350b0fac455d121d5cb7c43bda4e7286555612efd2934328320cdcb7be7fd068cc0f93399d8d9ac20bb91337
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
            -DKDE_INSTALL_DATAROOTDIR=data
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Parts)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
