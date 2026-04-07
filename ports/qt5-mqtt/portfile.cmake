include("${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake")

# No binary package for this port.
# qt_submodule_installation()

if(QT_UPDATE_VERSION)
    set(VCPKG_USE_HEAD_VERSION ON)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qt/qtmqtt
    REF 0b4955ce8b692409c3deded57892eb61e75be428
    HEAD_REF "v${QT_MAJOR_MINOR_VER}.${QT_PATCH_VER}"
    SHA512 4a16c277f338874c9606254f34c74c434a2f4df1767bd465822d1388f325de8c788d8ed184e1c340e092a358add6655e8d20d59a027f111d1882fcae6433320e
)

if(QT_UPDATE_VERSION)
    message(STATUS "New qtmqtt ref: ${VCPKG_HEAD_VERSION}")
endif()

# qt module builds from a git repository require a .git entry to invoke syncqt
file(WRITE "${SOURCE_PATH}/.git" "repocontent")

# syncqt is a perl script
vcpkg_find_acquire_program(PERL)
get_filename_component(perl_exe_path "${PERL}" DIRECTORY)
vcpkg_add_to_path("${perl_exe_path}")

qt_build_submodule("${SOURCE_PATH}")
qt_install_copyright("${SOURCE_PATH}")
