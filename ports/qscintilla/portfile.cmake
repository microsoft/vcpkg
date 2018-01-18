# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/QScintilla_gpl-2.10)
vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/pyqt/files/QScintilla2/QScintilla-2.10/QScintilla_gpl-2.10.zip"
    FILENAME "QScintilla_gpl-2.10.zip"
    SHA512 7c580cfee03af1056f530af756a0ff9cc2396a5419fa23aecc66a6bc8809a4fb154788956220bb0b068a5c214d571c053271c3906d6d541196fbbf7c6dbec917
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_find_acquire_program(PYTHON3)

# Add python3 to path
get_filename_component(PYTHON_PATH ${PYTHON3} DIRECTORY)
SET(ENV{PATH} "${PYTHON_PATH};$ENV{PATH}")

set(BUILD_OPTIONS
    "${SOURCE_PATH}/Qt4Qt5/qscintilla.pro"
    CONFIG+=build_all
    CONFIG-=hide_symbols
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(BUILD_OPTIONS
        ${BUILD_OPTIONS}
        CONFIG+=staticlib
    )
endif()

SET(ENV{PATH} "$ENV{PATH};${CURRENT_INSTALLED_DIR}/bin;${CURRENT_INSTALLED_DIR}/debug/bin")

#Store build paths
set(DEBUG_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
set(RELEASE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

file(REMOVE_RECURSE "${DEBUG_DIR}" "${RELEASE_DIR}")

#Configure debug
vcpkg_configure_qmake_debug(
    SOURCE_PATH ${SOURCE_PATH}/Qt4Qt5
)

#First generate the makefiles so we can modify them
vcpkg_build_qmake_debug(TARGETS qmake_all)

#Store debug makefiles path
file(GLOB_RECURSE DEBUG_MAKEFILES ${DEBUG_DIR}/*Makefile*)

foreach(DEBUG_MAKEFILE ${DEBUG_MAKEFILES})
    file(READ "${DEBUG_MAKEFILE}" _contents)
    string(REPLACE "zlib.lib" "zlibd.lib" _contents "${_contents}")
    string(REPLACE "installed\\${TARGET_TRIPLET}\\lib" "installed\\${TARGET_TRIPLET}\\debug\\lib" _contents "${_contents}")
    string(REPLACE "/LIBPATH:${NATIVE_INSTALLED_DIR}\\debug\\lib qtmaind.lib" "shell32.lib /LIBPATH:${NATIVE_INSTALLED_DIR}\\debug\\lib\\manual-link qtmaind.lib /LIBPATH:${NATIVE_INSTALLED_DIR}\\debug\\lib" _contents "${_contents}")
    file(WRITE "${DEBUG_MAKEFILE}" "${_contents}")
endforeach()

#Build debug
vcpkg_build_qmake_debug(TARGETS debug)

#Configure release
vcpkg_configure_qmake_release(
    SOURCE_PATH ${SOURCE_PATH}/Qt4Qt5
)

#First generate the makefiles so we can modify them
vcpkg_build_qmake_release(TARGETS qmake_all)

#Store release makefile path
file(GLOB_RECURSE RELEASE_MAKEFILES ${RELEASE_DIR}/*Makefile*)

foreach(RELEASE_MAKEFILE ${RELEASE_MAKEFILES})
    file(READ "${RELEASE_MAKEFILE}" _contents)
    string(REPLACE "/LIBPATH:${NATIVE_INSTALLED_DIR}\\lib qtmain.lib" "shell32.lib /LIBPATH:${NATIVE_INSTALLED_DIR}\\lib\\manual-link qtmain.lib /LIBPATH:${NATIVE_INSTALLED_DIR}\\lib" _contents "${_contents}")
    file(WRITE "${RELEASE_MAKEFILE}" "${_contents}")
endforeach()

#Build release
vcpkg_build_qmake_release(TARGETS release)

#Set the correct install directory to packages
foreach(MAKEFILE ${RELEASE_MAKEFILES} ${DEBUG_MAKEFILES})
    vcpkg_replace_string(${MAKEFILE} "(INSTALL_ROOT)${INSTALLED_DIR_WITHOUT_DRIVE}" "(INSTALL_ROOT)${PACKAGES_DIR_WITHOUT_DRIVE}")
endforeach()

set(BUILD_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})

file(GLOB HEADER_FILES ${SOURCE_PATH}/Qt4Qt5/Qsci/*)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/Qsci)

file(INSTALL
    ${RELEASE_DIR}/release/qscintilla2_qt5.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    RENAME qscintilla2.lib
)

file(INSTALL
    ${DEBUG_DIR}/debug/qscintilla2_qt5.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    RENAME qscintilla2.lib
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
   file(INSTALL
       ${RELEASE_DIR}/release/qscintilla2_qt5.dll
       DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )

    file(INSTALL
        ${DEBUG_DIR}/debug/qscintilla2_qt5.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )

vcpkg_copy_pdbs()

endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/qscintilla)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/qscintilla/LICENSE ${CURRENT_PACKAGES_DIR}/share/qscintilla/copyright)
