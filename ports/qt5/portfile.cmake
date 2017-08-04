include(vcpkg_common_functions)

string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
if(BUILDTREES_PATH_LENGTH GREATER 27)
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

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/qt-5.8.0)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://download.qt.io/official_releases/qt/5.8/5.8.0/single/qt-everywhere-opensource-src-5.8.0.7z"
    FILENAME "qt-5.8.0.7z"
    SHA512 4c8e7931f0c48318871242c12c2d6f5406be40e037f18690017198a79ef40a72d4319ecb1b8fb5f97c080dbe30174ceb5fd604b3fab22489f977cbeee3e8abe7
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})
if (EXISTS ${CURRENT_BUILDTREES_DIR}/src/qt-everywhere-opensource-src-5.8.0)
    file(RENAME ${CURRENT_BUILDTREES_DIR}/src/qt-everywhere-opensource-src-5.8.0 ${CURRENT_BUILDTREES_DIR}/src/qt-5.8.0)
endif()

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-qalgorithms-vs2017.patch" "${CMAKE_CURRENT_LIST_DIR}/fix-commandline-overrides.patch"
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
        -sql-sqlite
        -sql-psql
        -nomake examples -nomake tests
        -skip webengine
        -opengl desktop # other options are "-no-opengl" and "-opengl angle"
        -mp
        LIBJPEG_LIBS="-ljpeg"
    OPTIONS_RELEASE
        ZLIB_LIBS="-lzlib"
        LIBPNG_LIBS="-llibpng16"
    OPTIONS_DEBUG
        ZLIB_LIBS="-lzlibd"
        LIBPNG_LIBS="-llibpng16d"
        PCRE_LIBS="-lpcre16d"
        PSQL_LIBS="-llibpqd"
        FREETYPE_LIBS="-lfreetyped"
)
install_qt()

vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_PACKAGES_DIR}/lib/cmake
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/add-private-header-paths.patch"
)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*.exe")
file(INSTALL ${BINARY_TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qt5)
file(REMOVE ${BINARY_TOOLS})
file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
file(REMOVE ${BINARY_TOOLS})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_execute_required_process(
    COMMAND ${PYTHON3} ${CMAKE_CURRENT_LIST_DIR}/fixcmake.py
    WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/cmake
    LOGNAME fix-cmake
)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(INSTALL ${SOURCE_PATH}/LICENSE.LGPLv3 DESTINATION  ${CURRENT_PACKAGES_DIR}/share/qt5 RENAME copyright)
if(EXISTS ${CURRENT_PACKAGES_DIR}/plugins)
    file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/qtdeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/plugins)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/plugins)
    file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/qtdeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/debug/plugins)
endif()
