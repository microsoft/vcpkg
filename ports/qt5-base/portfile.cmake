include(vcpkg_common_functions)

string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
if(BUILDTREES_PATH_LENGTH GREATER 37)
    message(WARNING "Qt5's buildsystem uses very long paths and may fail on your system.\n"
        "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Qt5 doesn't currently support static builds. Please use a dynamic triplet instead.")
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(configure_qt)
include(install_qt)

set(SRCDIR_NAME "qtbase-5.9.2")
set(ARCHIVE_NAME "qtbase-opensource-src-5.9.2")
set(ARCHIVE_EXTENSION ".tar.xz")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${SRCDIR_NAME})
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://download.qt.io/official_releases/qt/5.9/5.9.2/submodules/${ARCHIVE_NAME}${ARCHIVE_EXTENSION}"
    FILENAME ${SRCDIR_NAME}${ARCHIVE_EXTENSION}
    SHA512 a2f965871645256f3d019f71f3febb875455a29d03fccc7a3371ddfeb193b0af12394e779df05adf69fd10fe7b0d966f3915a24528ec7eb3bc36c2db6af2b6e7
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})
if (EXISTS ${CURRENT_BUILDTREES_DIR}/src/${ARCHIVE_NAME})
    file(RENAME ${CURRENT_BUILDTREES_DIR}/src/${ARCHIVE_NAME} ${CURRENT_BUILDTREES_DIR}/src/${SRCDIR_NAME})
endif()

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/fix-system-pcre2.patch"
        "${CMAKE_CURRENT_LIST_DIR}/fix-system-freetype.patch"
)

# This fixes issues on machines with default codepages that are not ASCII compatible, such as some CJK encodings
set(ENV{_CL_} "/utf-8")

configure_qt(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -confirm-license
        -opensource
        -system-zlib
        -system-libjpeg
        -system-libpng
        -system-freetype
        -system-pcre
        -system-harfbuzz
        -system-doubleconversion
        -system-sqlite
        -no-fontconfig
        -sql-sqlite
        -sql-psql
        -nomake examples -nomake tests
        -opengl desktop # other options are "-no-opengl" and "-opengl angle"
        -mp
        LIBJPEG_LIBS="-ljpeg"
    OPTIONS_RELEASE
        ZLIB_LIBS="-lzlib"
        LIBPNG_LIBS="-llibpng16"
        FREETYPE_LIBS="-lfreetype"
    OPTIONS_DEBUG
        ZLIB_LIBS="-lzlibd"
        LIBPNG_LIBS="-llibpng16d"
        PSQL_LIBS="-llibpqd"
        FREETYPE_LIBS="-lfreetyped"
)

install_qt()

file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*.exe")
file(INSTALL ${BINARY_TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qt5)
file(REMOVE ${BINARY_TOOLS})
file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
file(REMOVE ${BINARY_TOOLS})
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/qt_debug.conf ${CMAKE_CURRENT_LIST_DIR}/qt_release.conf DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qt5)

vcpkg_execute_required_process(
    COMMAND ${PYTHON3} ${CMAKE_CURRENT_LIST_DIR}/fixcmake.py
    WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/cmake
    LOGNAME fix-cmake
)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/qt5)

#---------------------------------------------------------------------------
# qtmain(d) vs. Qt5AxServer(d)
#---------------------------------------------------------------------------
# Qt applications have to either link to qtmain(d) or to Qt5AxServer(d),
# never both. See http://doc.qt.io/qt-5/activeqt-server.html for more info.
#
# Create manual-link folders:
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/manual-link)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
#
# Either have users explicitly link against qtmain.lib, qtmaind.lib:
file(COPY ${CURRENT_PACKAGES_DIR}/lib/qtmain.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/manual-link)
file(COPY ${CURRENT_PACKAGES_DIR}/lib/qtmain.prl DESTINATION ${CURRENT_PACKAGES_DIR}/lib/manual-link)
file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/qtmain.lib)
file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/qtmain.prl)
file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/qtmaind.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/qtmaind.prl DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/qtmaind.lib)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/qtmaind.prl)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/qtdeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/plugins)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/qtdeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/debug/plugins)

file(INSTALL ${SOURCE_PATH}/LICENSE.LGPLv3 DESTINATION  ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
