# vcpkg_from_* is not used because the project uses submodules.
string(REGEX MATCH "^([0-9]*[.][0-9]*)" GI_MAJOR_MINOR "${VERSION}")
set(GI_PATCH 0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/gobject-introspection/${GI_MAJOR_MINOR}/gobject-introspection-${VERSION}.tar.xz"
    FILENAME "gobject-introspection-${VERSION}.tar.xz"
    SHA512 e139fadb4174c72b648914f3774d89fc0e5eaee45bba0c13edf05de883664dad8276dbc34006217bb09871ed4bad23adab51ff232a17b9eb131329b2926cafb7
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        0001-g-ir-tool-template.in.patch
        0002-cross-build.patch
        0003-fix-paths.patch
        0004-fastcall.patch # https://gitlab.gnome.org/GNOME/gobject-introspection/-/merge_requests/498
)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

set(OPTIONS_DEBUG -Dbuild_introspection_data=false)
set(OPTIONS_RELEASE -Dbuild_introspection_data=true)
if(CMAKE_HOST_WIN32 AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(PYTHON_DIR ${CURRENT_INSTALLED_DIR})
else()
    set(PYTHON_DIR ${CURRENT_HOST_INSTALLED_DIR})

    if(VCPKG_CROSSCOMPILING)
        # this is work in progress
        list(APPEND OPTIONS_RELEASE -Dgi_cross_use_prebuilt_gi=true)
    endif()
endif()

find_file(INITIAL_PYTHON3
    NAMES "python3${VCPKG_HOST_EXECUTABLE_SUFFIX}" "python${VCPKG_HOST_EXECUTABLE_SUFFIX}"
    PATHS "${PYTHON_DIR}/tools/python3"
    NO_DEFAULT_PATH
    REQUIRED
)
x_vcpkg_get_python_packages(OUT_PYTHON_VAR PYTHON3
    PYTHON_EXECUTABLE "${INITIAL_PYTHON3}"
    PYTHON_VERSION "3"
    PACKAGES setuptools
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        ${OPTIONS_DEBUG}
    OPTIONS_RELEASE
        ${OPTIONS_RELEASE}
    ADDITIONAL_BINARIES
        flex='${FLEX}'
        bison='${BISON}'
        g-ir-annotation-tool='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-annotation-tool'
        g-ir-compiler='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-compiler${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        g-ir-scanner='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-scanner'
        python='${PYTHON3}'
)

vcpkg_host_path_list(APPEND ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/lib/pkgconfig")
vcpkg_host_path_list(APPEND ENV{LIB} "${CURRENT_INSTALLED_DIR}/lib")
vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

set(GI_TOOLS
        g-ir-compiler
        g-ir-generate
        g-ir-inspect
)
set(GI_SCRIPTS
        g-ir-annotation-tool
        g-ir-scanner
)

vcpkg_copy_tools(TOOL_NAMES ${GI_TOOLS} AUTO_CLEAN)
foreach(script IN LISTS GI_SCRIPTS)
    file(READ "${CURRENT_PACKAGES_DIR}/bin/${script}" _contents)
    string(REPLACE "#!/usr/bin/env ${PYTHON3}" "#!/usr/bin/env python3" _contents "${_contents}")
    string(REPLACE "datadir = \"${CURRENT_PACKAGES_DIR}/share\"" "raise Exception('could not find right path') " _contents "${_contents}")
    string(REPLACE "pylibdir = os.path.join('${CURRENT_PACKAGES_DIR}/lib', 'gobject-introspection')" "raise Exception('could not find right path') " _contents "${_contents}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${script}" "${_contents}")

    file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${script}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${script}")
endforeach()

if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB _pyd_lib_files "${CURRENT_PACKAGES_DIR}/lib/gobject-introspection/giscanner/_giscanner.*.lib")
    file(REMOVE ${_pyd_lib_files})
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
