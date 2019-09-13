include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)
#qt_submodule_installation() No binary package for this port. 

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qt/qtmqtt
    REF v${QT_MAJOR_MINOR_VER}.${QT_PATCH_VER}
    SHA512 ${QT_HASH_${PORT}}
)

if(QT_UPDATE_VERSION)
    file(SHA512 "${ARCHIVE_FILE}" ARCHIVE_HASH)
    message(STATUS "${PORT} new hash is ${ARCHIVE_HASH}")
    file(APPEND "${VCPKG_ROOT_DIR}/ports/qt5-base/cmake/qt_new_hashes.cmake" "set(QT_HASH_${PORT} ${ARCHIVE_HASH})\n")
    SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()
    # qt module builds from a git repository require a .git entry to invoke syncqt
    file(WRITE "${SOURCE_PATH}/.git" "repocontent")

    # syncqt is a perl script
    vcpkg_find_acquire_program(PERL)
    get_filename_component(perl_exe_path ${PERL} DIRECTORY)
    vcpkg_add_to_path("${perl_exe_path}")

    qt_build_submodule(${SOURCE_PATH})
    qt_install_copyright(${SOURCE_PATH})
endif()
