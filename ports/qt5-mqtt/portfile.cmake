include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)
#qt_submodule_installation() No binary package for this port. 
if(QT_UPDATE_VERSION)
    set(UPDATE_PORT_GIT_OPTIONS X_OUT_REF NEW_REF) # TO get an SHA512 error if the variable is set. 
endif()

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL git://code.qt.io/qt/qtmqtt.git
    TAG v${QT_MAJOR_MINOR_VER}.${QT_PATCH_VER}
    REF ${QT_HASH_${PORT}}
    ${UPDATE_PORT_GIT_OPTIONS}
    PATCHES ${_qis_PATCHES}
)

if(NEW_REF)
    message(STATUS "New qtmqtt ref: ${NEW_REF}")
endif()

# qt module builds from a git repository require a .git entry to invoke syncqt
file(WRITE "${SOURCE_PATH}/.git" "repocontent")

# syncqt is a perl script
vcpkg_find_acquire_program(PERL)
get_filename_component(perl_exe_path ${PERL} DIRECTORY)
vcpkg_add_to_path("${perl_exe_path}")

qt_build_submodule(${SOURCE_PATH})
qt_install_copyright(${SOURCE_PATH})
