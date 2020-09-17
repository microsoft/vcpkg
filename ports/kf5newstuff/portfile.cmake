vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/knewstuff
    REF v5.73.0
    SHA512 b5e86e7589143dc68f02d8e8e62780940d9b1a54eb4d82bcb970912169e28cb9fddfa27c23497966388552964a4cf1a678d7bc9d6ed3fa5d0d5173d8ccfaa3b1
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
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5NewStuff DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5NewStuffCore TARGET_PATH share/KF5NewStuffCore)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/qml ${CURRENT_PACKAGES_DIR}/debug/qml )
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/qml ${CURRENT_PACKAGES_DIR}/qml )

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")	
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")	
elseif(VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/knewstuff-dialog${VCPKG_HOST_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/debug/bin/knewstuff-dialog${VCPKG_HOST_EXECUTABLE_SUFFIX}")	
endif()


file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
