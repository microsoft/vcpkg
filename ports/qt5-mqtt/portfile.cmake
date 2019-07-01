include(vcpkg_common_functions)

include(${CURRENT_INSTALLED_DIR}/share/qt5modularscripts/qt_modular_library.cmake)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qt/qtmqtt
    REF cf41d84738f0ed0c779f75db94d413ad938fb901
    SHA512 e9a818999e4befb0b945d609a1ee28a3e2d7e3b6d8c12ab82ae827fdb8f6bf5e8b82114c1850438d634fa24c9ac608ebae1d461385bd4e088f8cabf7eec0182c
    HEAD_REF dev
)

# Qt module builds from a git repository require a .git entry to invoke syncqt
file(WRITE "${SOURCE_PATH}/.git" "repocontent")

# syncqt is a PERL script
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
set(ENV{PATH} "${PERL_EXE_PATH};$ENV{PATH}")

qt_modular_build_library(${SOURCE_PATH})
