set(VCPKG_BUILD_TYPE release) # headers only

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mobile-broadband/ModemManager
    REF "${VERSION}"
    SHA512 341a795e6aa4f76f606a57921511233eb68510bea0bc6967449e2d2bb5949106c7d17ae964683797734c1cd688ac15ad076e08cc1d54aee22a16d23a9ca61510
    HEAD_REF main
)

set(include_dir "${CURRENT_PACKAGES_DIR}/include/ModemManager")
file(INSTALL
    "${SOURCE_PATH}/include/ModemManager.h"
    "${SOURCE_PATH}/include/ModemManager-compat.h"
    "${SOURCE_PATH}/include/ModemManager-enums.h"
    "${SOURCE_PATH}/include/ModemManager-errors.h"
    DESTINATION "${include_dir}"
)

if(NOT XLSTPROC)
    find_program(XLSTPROC NAMES "xsltproc${VCPKG_HOST_EXECUTABLE_SUFFIX}" PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/libxslt" PATH_SUFFIXES "bin")
endif()
if(NOT XLSTPROC)
    message(FATAL_ERROR "${PORT} requires xsltproc for the host system. Please install libxslt within vcpkg or your system package manager!")
endif()
vcpkg_execute_required_process(
    COMMAND "${XLSTPROC}" --xinclude --nonet
        --output "${include_dir}/ModemManager-names.h"
        "${SOURCE_PATH}/build-aux/header-generator.xsl"
        "${SOURCE_PATH}/introspection/all.xml"
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME "xsltproc-${TARGET_TRIPLET}"
)

string(REPLACE "." ";" version_list "${VERSION}")
list(GET version_list 0 MM_MAJOR_VERSION)
list(GET version_list 1 MM_MINOR_VERSION)
list(GET version_list 2 MM_MICRO_VERSION)
configure_file("${SOURCE_PATH}/include/ModemManager-version.h.in" "${include_dir}/ModemManager-version.h" @ONLY)

set(prefix "${CURRENT_PACKAGES_DIR}")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")
configure_file("${SOURCE_PATH}/data/ModemManager.pc.in" "${CURRENT_PACKAGES_DIR}/share/pkgconfig/ModemManager.pc" @ONLY)
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LIB")
