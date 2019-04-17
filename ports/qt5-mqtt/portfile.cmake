include(vcpkg_common_functions)

include(${CURRENT_INSTALLED_DIR}/share/qt5modularscripts/qt_modular_library.cmake)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qt/qtmqtt
    REF v5.12.1
    SHA512 c6f4000a032caaf5224ca6fe2442f22eddc26e3e53cc101885c717b706156cada716e45ff92d267928b87e1e5ceae5e81694f4b7c289d9836e75f27fd012de42
    HEAD_REF dev
)

# Qt module builds from a git repository require a .git entry to invoke syncqt
file(WRITE "${SOURCE_PATH}/.git" "repocontent")

# syncqt is a PERL script
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
set(ENV{PATH} "${PERL_EXE_PATH};$ENV{PATH}")

qt_modular_build_library(${SOURCE_PATH})
