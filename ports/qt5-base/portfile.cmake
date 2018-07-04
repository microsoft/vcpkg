include(vcpkg_common_functions)

string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
if(BUILDTREES_PATH_LENGTH GREATER 37 AND CMAKE_HOST_WIN32)
    message(WARNING "Qt5's buildsystem uses very long paths and may fail on your system.\n"
        "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
    )
endif()

if((NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore") AND VCPKG_LIBRARY_LINKAGE STREQUAL static)
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

# Remove vendored dependencies to ensure they are not picked up by the build
foreach(DEPENDENCY freetype zlib harfbuzzng libjpeg libpng double-conversion)
    if(EXISTS ${SOURCE_PATH}/src/3rdparty/${DEPENDENCY})
        file(REMOVE_RECURSE ${SOURCE_PATH}/src/3rdparty/${DEPENDENCY})
    endif()
endforeach()

file(REMOVE_RECURSE ${SOURCE_PATH}/include/QtZlib)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/fix-system-pcre2.patch"
        "${CMAKE_CURRENT_LIST_DIR}/fix-system-freetype.patch"
        "${CMAKE_CURRENT_LIST_DIR}/fix-system-pcre2-linux.patch"
		"${CMAKE_CURRENT_LIST_DIR}/fix-C3615.patch"
)

# This fixes issues on machines with default codepages that are not ASCII compatible, such as some CJK encodings
set(ENV{_CL_} "/utf-8")

set(CORE_OPTIONS
    -confirm-license
    -opensource
    -system-zlib
    -system-libjpeg
    -system-libpng
    -system-freetype
    -system-pcre
    -system-harfbuzz
    -system-doubleconversion
    -no-fontconfig
    -nomake examples -nomake tests
)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    if(VCPKG_PLATFORM_TOOLSET MATCHES "v140")
        set(PLATFORM "win32-msvc2015")
    elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
        set(PLATFORM "win32-msvc2017")
    elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v120")
        set(PLATFORM "win32-msvc2013")
    endif()
    configure_qt(
        SOURCE_PATH ${SOURCE_PATH}
        PLATFORM ${PLATFORM}
        OPTIONS
            ${CORE_OPTIONS}
            -sql-sqlite
            -sql-psql
            -system-sqlite
            -mp
            -opengl desktop # other options are "-no-opengl", "-opengl angle", and "-opengl desktop"
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
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    configure_qt(
        SOURCE_PATH ${SOURCE_PATH}
        PLATFORM "linux-g++"
        OPTIONS
            ${CORE_OPTIONS}
            -no-sqlite
            -no-opengl # other options are "-no-opengl", "-opengl angle", and "-opengl desktop"
            LIBJPEG_LIBS="-ljpeg"
        OPTIONS_RELEASE
            "QMAKE_LIBS_PRIVATE+=${CURRENT_INSTALLED_DIR}/lib/libpng16.a"
            "QMAKE_LIBS_PRIVATE+=${CURRENT_INSTALLED_DIR}/lib/libz.a"
            "ZLIB_LIBS=${CURRENT_INSTALLED_DIR}/lib/libz.a"
            "LIBPNG_LIBS=${CURRENT_INSTALLED_DIR}/lib/libpng16.a"
            "FREETYPE_LIBS=${CURRENT_INSTALLED_DIR}/lib/libfreetype.a"
            "PSQL_LIBS=${CURRENT_INSTALLED_DIR}/lib/libpq.a ${CURRENT_INSTALLED_DIR}/lib/libssl.a ${CURRENT_INSTALLED_DIR}/lib/libcrypto.a"
        OPTIONS_DEBUG
            "QMAKE_LIBS_PRIVATE+=${CURRENT_INSTALLED_DIR}/debug/lib/libpng16d.a"
            "QMAKE_LIBS_PRIVATE+=${CURRENT_INSTALLED_DIR}/debug/lib/libz.a"
            "ZLIB_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libz.a"
            "LIBPNG_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libpng16d.a"
            "FREETYPE_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libfreetyped.a"
            "PSQL_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libpqd.a ${CURRENT_INSTALLED_DIR}/debug/lib/libssl.a ${CURRENT_INSTALLED_DIR}/debug/lib/libcrypto.a"
    )
endif()

install_qt()

file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*")
list(FILTER BINARY_TOOLS EXCLUDE REGEX "\\.dll\$")
file(INSTALL ${BINARY_TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qt5)
file(REMOVE ${BINARY_TOOLS})
file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/debug/bin/*")
list(FILTER BINARY_TOOLS EXCLUDE REGEX "\\.dll\$")
file(REMOVE ${BINARY_TOOLS})
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/qt_debug.conf ${CMAKE_CURRENT_LIST_DIR}/qt_release.conf DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qt5)

vcpkg_execute_required_process(
    COMMAND ${PYTHON3} ${CMAKE_CURRENT_LIST_DIR}/fixcmake.py
    WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/cmake
    LOGNAME fix-cmake
)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/qt5)

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/qtmain.lib)
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
endif()

file(GLOB_RECURSE PRL_FILES "${CURRENT_PACKAGES_DIR}/lib/*.prl" "${CURRENT_PACKAGES_DIR}/debug/lib/*.prl")
file(TO_CMAKE_PATH "${CURRENT_INSTALLED_DIR}/lib" CMAKE_RELEASE_LIB_PATH)
file(TO_CMAKE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib" CMAKE_DEBUG_LIB_PATH)
foreach(PRL_FILE IN LISTS PRL_FILES)
    file(READ "${PRL_FILE}" _contents)
    string(REPLACE "${CMAKE_RELEASE_LIB_PATH}" "\$\$[QT_INSTALL_LIBS]" _contents "${_contents}")
    string(REPLACE "${CMAKE_DEBUG_LIB_PATH}" "\$\$[QT_INSTALL_LIBS]" _contents "${_contents}")
    file(WRITE "${PRL_FILE}" "${_contents}")
endforeach()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/qtdeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/plugins)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/qtdeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/debug/plugins)

file(INSTALL ${SOURCE_PATH}/LICENSE.LGPLv3 DESTINATION  ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
