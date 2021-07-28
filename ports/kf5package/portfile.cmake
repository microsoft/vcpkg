vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kpackage
    REF v5.75.0
    SHA512 8498fbd6bb2ed2fc37feab2e248f9d56800dafda27d993e6eefc66e383e74f58aa237c8813f92f03f5aec0afe03c4e0ca76d1dc71e9f0c9d69e0a08627b5ecd2
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
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Package)
vcpkg_copy_pdbs()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/kpackagetool5${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/kpackagetool5${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/${PORT}/kpackagetool5${VCPKG_HOST_EXECUTABLE_SUFFIX})

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSES/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)