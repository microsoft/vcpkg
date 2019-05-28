include(vcpkg_common_functions)

string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
if(BUILDTREES_PATH_LENGTH GREATER 37 AND CMAKE_HOST_WIN32)
    message(WARNING "Qt5's buildsystem uses very long paths and may fail on your system.\n"
        "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
    )
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(configure_qt)
include(install_qt)

set(MAJOR_MINOR 5.12)
set(FULL_VERSION ${MAJOR_MINOR}.3)
set(ARCHIVE_NAME "qtbase-everywhere-src-${FULL_VERSION}.tar.xz")

vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://download.qt.io/official_releases/qt/${MAJOR_MINOR}/${FULL_VERSION}/submodules/${ARCHIVE_NAME}"
    FILENAME ${ARCHIVE_NAME}
    SHA512 1dab927573eb22b1ae772de3a418f7d3999ea78d6e667a7f2494390dd1f0981ea93f4f892cb6e124ac18812c780ee71da3021b485c61eaf1ef2234a5c12b7fe2
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE_FILE}"
    REF ${FULL_VERSION}
)

# Remove vendored dependencies to ensure they are not picked up by the build
foreach(DEPENDENCY freetype zlib harfbuzzng libjpeg libpng double-conversion sqlite)
    if(EXISTS ${SOURCE_PATH}/src/3rdparty/${DEPENDENCY})
        file(REMOVE_RECURSE ${SOURCE_PATH}/src/3rdparty/${DEPENDENCY})
    endif()
endforeach()

file(REMOVE_RECURSE ${SOURCE_PATH}/include/QtZlib)

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
    -system-doubleconversion
    -system-sqlite
    -system-harfbuzz
    -no-fontconfig
    -nomake examples
    -nomake tests
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND CORE_OPTIONS
        -static
    )
    set(JPEG_STATIC_POSTFIX "-static")
else()
    set(JPEG_STATIC_POSTFIX "")
endif()

set(VCPKG_RELEASE_LIBDIR "${CURRENT_INSTALLED_DIR}/lib")
set(VCPKG_DEBUG_LIBDIR "${CURRENT_INSTALLED_DIR}/debug/lib")

if(WIN32)
    set(CMAKE_FIND_LIBRARY_PREFIXES "")
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".lib")
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(CMAKE_FIND_LIBRARY_PREFIXES "lib")
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".so;.a")
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(CMAKE_FIND_LIBRARY_PREFIXES "lib")
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".dylib;.so;.a")
endif()
find_library(LIBJPEG_LIBS_RELEASE   NAMES jpeg${JPEG_STATIC_POSTFIX}   PATHS "${VCPKG_RELEASE_LIBDIR}" NO_DEFAULT_PATH)
find_library(LIBJPEG_LIBS_DEBUG     NAMES jpeg${JPEG_STATIC_POSTFIX}d  PATHS "${VCPKG_DEBUG_LIBDIR}"   NO_DEFAULT_PATH)
find_library(ZLIB_LIBS_RELEASE      NAMES zlib z                       PATHS "${VCPKG_RELEASE_LIBDIR}" NO_DEFAULT_PATH)
find_library(ZLIB_LIBS_DEBUG        NAMES zlibd zd                     PATHS "${VCPKG_DEBUG_LIBDIR}"   NO_DEFAULT_PATH)
find_library(LIBPNG_LIBS_RELEASE    NAMES png16 libpng16               PATHS "${VCPKG_RELEASE_LIBDIR}" NO_DEFAULT_PATH)
find_library(LIBPNG_LIBS_DEBUG      NAMES png16d libpng16d             PATHS "${VCPKG_DEBUG_LIBDIR}"   NO_DEFAULT_PATH)
find_library(PSQL_LIBS_RELEASE      NAMES pq libpq                     PATHS "${VCPKG_RELEASE_LIBDIR}" NO_DEFAULT_PATH)
find_library(PSQL_LIBS_DEBUG        NAMES pqd libpqd                   PATHS "${VCPKG_DEBUG_LIBDIR}"   NO_DEFAULT_PATH)
find_library(PCRE2_LIBS_RELEASE     NAMES pcre2-16                     PATHS "${VCPKG_RELEASE_LIBDIR}" NO_DEFAULT_PATH)
find_library(PCRE2_LIBS_DEBUG       NAMES pcre2-16d                    PATHS "${VCPKG_DEBUG_LIBDIR}"   NO_DEFAULT_PATH)
find_library(FREETYPE_LIBS_RELEASE  NAMES freetype                     PATHS "${VCPKG_RELEASE_LIBDIR}" NO_DEFAULT_PATH)
find_library(FREETYPE_LIBS_DEBUG    NAMES freetyped                    PATHS "${VCPKG_DEBUG_LIBDIR}"   NO_DEFAULT_PATH)
find_library(HARFBUZZ_LIBS_RELEASE  NAMES harfbuzz                     PATHS "${VCPKG_RELEASE_LIBDIR}" NO_DEFAULT_PATH)
find_library(HARFBUZZ_LIBS_DEBUG    NAMES harfbuzz                     PATHS "${VCPKG_DEBUG_LIBDIR}"   NO_DEFAULT_PATH)
find_library(OPENSSL_RELEASE        NAMES ssl ssleay32                 PATHS "${VCPKG_RELEASE_LIBDIR}" NO_DEFAULT_PATH)
find_library(OPENSSL_DEBUG          NAMES ssl ssleay32                 PATHS "${VCPKG_DEBUG_LIBDIR}"   NO_DEFAULT_PATH) # will also need d in future
find_library(OPENSSL_CRYPTO_RELEASE NAMES crypto libeay32              PATHS "${VCPKG_RELEASE_LIBDIR}" NO_DEFAULT_PATH)
find_library(OPENSSL_CRYPTO_DEBUG   NAMES crypto libeay32              PATHS "${VCPKG_DEBUG_LIBDIR}"   NO_DEFAULT_PATH) # will also need d in future
find_library(SQLITE_LIBS_RELEASE    NAMES sqlite3                      PATHS "${VCPKG_RELEASE_LIBDIR}" NO_DEFAULT_PATH)
find_library(SQLITE_LIBS_DEBUG      NAMES sqlite3                      PATHS "${VCPKG_DEBUG_LIBDIR}"   NO_DEFAULT_PATH) 

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(QT5Deps
    REQUIRED_VARS 
    LIBJPEG_LIBS_RELEASE LIBJPEG_LIBS_DEBUG 
    ZLIB_LIBS_RELEASE ZLIB_LIBS_DEBUG
    LIBPNG_LIBS_RELEASE LIBPNG_LIBS_DEBUG
    PSQL_LIBS_RELEASE PSQL_LIBS_DEBUG
    PCRE2_LIBS_RELEASE PCRE2_LIBS_DEBUG
    FREETYPE_LIBS_RELEASE FREETYPE_LIBS_DEBUG
    HARFBUZZ_LIBS_RELEASE HARFBUZZ_LIBS_DEBUG
    OPENSSL_RELEASE OPENSSL_DEBUG
    OPENSSL_CRYPTO_RELEASE OPENSSL_CRYPTO_DEBUG
    SQLITE_LIBS_RELEASE SQLITE_LIBS_DEBUG
    )
if(NOT QT5Deps_FOUND)
    message(FATAL_ERROR Not all dependencies found!)
endif()

if(NOT WIN32)

    set(PSQL_LIBS_RELEASE "${PSQL_LIBS_RELEASE} ${OPENSSL_RELEASE} ${OPENSSL_CRYPTO_RELEASE} -ldl -lpthread")
    set(PSQL_LIBS_DEBUG "${PSQL_LIBS_DEBUG} ${OPENSSL_DEBUG} ${OPENSSL_CRYPTO_DEBUG} -ldl -lpthread")

    set(SQLITE_LIBS_RELEASE "${SQLITE_LIBS_RELEASE} -ldl -lpthread")
    set(SQLITE_LIBS_DEBUG "${SQLITE_LIBS_DEBUG} -ldl -lpthread")
    if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        set(HARFBUZZ_LIBS_RELEASE "${HARFBUZZ_LIBS_RELEASE} -framework ApplicationServices")
        set(HARFBUZZ_LIBS_DEBUG "${HARFBUZZ_LIBS_DEBUG} -framework ApplicationServices")
    endif()
endif()

set(QT_OPTIONS_RELEASE)
set(QT_OPTIONS_DEBUG)
list(APPEND QT_OPTIONS_RELEASE
        ZLIB_LIBS="${ZLIB_LIBS_RELEASE}"
        LIBPNG_LIBS="${LIBPNG_LIBS_RELEASE}"
        LIBJPEG_LIBS="${LIBJPEG_LIBS_RELEASE}"
        PSQL_LIBS="${PSQL_LIBS_RELEASE}"
        PCRE2_LIBS="${PCRE2_LIBS_RELEASE}"
        FREETYPE_LIBS="${FREETYPE_LIBS_RELEASE}"
        )
list(APPEND QT_OPTIONS_DEBUG
        ZLIB_LIBS="${ZLIB_LIBS_DEBUG}"
        LIBPNG_LIBS="${LIBPNG_LIBS_DEBUG}"
        LIBJPEG_LIBS="${LIBJPEG_LIBS_DEBUG}"
        PSQL_LIBS="${PSQL_LIBS_DEBUG}"
        PCRE2_LIBS="${PCRE2_LIBS_DEBUG}"
        FREETYPE_LIBS="${FREETYPE_LIBS_DEBUG}"
        )
if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(PLATFORM "win32-msvc")
    list(APPEND CORE_OPTIONS
            -mp
            -opengl dynamic # other options are "-no-opengl", "-opengl angle", and "-opengl desktop"
        )
    list(APPEND QT_OPTIONS_RELEASE
            ZLIB_LIBS="${ZLIB_LIBS_RELEASE}"
            LIBPNG_LIBS="${LIBPNG_LIBS_RELEASE}"
        )
    list(APPEND QT_OPTIONS_DEBUG
            ZLIB_LIBS="${ZLIB_LIBS_DEBUG}"
            LIBPNG_LIBS="${LIBPNG_LIBS_DEBUG}"
        )
else()
    list(APPEND QT_OPTIONS_RELEASE
            "QMAKE_LIBS_PRIVATE+=${LIBPNG_LIBS_RELEASE}"
            "QMAKE_LIBS_PRIVATE+=${ZLIB_LIBS_RELEASE}"
            "SQLITE_LIBS=${SQLITE_LIBS_RELEASE}"
        )
    list(APPEND QT_OPTIONS_DEBUG
            "QMAKE_LIBS_PRIVATE+=${LIBPNG_LIBS_DEBUG}"
            "QMAKE_LIBS_PRIVATE+=${ZLIB_LIBS_DEBUG}"
            "SQLITE_LIBS=${SQLITE_LIBS_DEBUG}"
        )
    if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
        set(PLATFORM "linux-g++")
    elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        set(PLATFORM "macx-clang")
        list(APPEND QT_OPTIONS_RELEASE
                "HARFBUZZ_LIBS=${HARFBUZZ_LIBS_RELEASE}"
            )
        list(APPEND QT_OPTIONS_DEBUG 
                "HARFBUZZ_LIBS=${HARFBUZZ_LIBS_DEBUG}"
            )
    endif()
endif()

configure_qt(
    SOURCE_PATH ${SOURCE_PATH}
    PLATFORM ${PLATFORM}
    OPTIONS
        ${CORE_OPTIONS}
    OPTIONS_RELEASE
        ${QT_OPTIONS_RELEASE}
    OPTIONS_DEBUG
        ${QT_OPTIONS_DEBUG}
    )

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    install_qt(DISABLE_PARALLEL) # prevent race condition on Mac
else()
    install_qt()
endif()

file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*")
    list(FILTER BINARY_TOOLS EXCLUDE REGEX "\\.dll\$")
    file(INSTALL ${BINARY_TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qt5)
    file(REMOVE ${BINARY_TOOLS})

    file(COPY ${CMAKE_CURRENT_LIST_DIR}/qt_release.conf DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qt5)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/debug/bin/*")
    list(FILTER BINARY_TOOLS EXCLUDE REGEX "\\.dll\$")
    file(REMOVE ${BINARY_TOOLS})
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()

    file(COPY ${CMAKE_CURRENT_LIST_DIR}/qt_debug.conf DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qt5)
endif()

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
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/manual-link)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
    endif()
    #
    # Either have users explicitly link against qtmain.lib, qtmaind.lib:
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(COPY ${CURRENT_PACKAGES_DIR}/lib/qtmain.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/manual-link)
        file(COPY ${CURRENT_PACKAGES_DIR}/lib/qtmain.prl DESTINATION ${CURRENT_PACKAGES_DIR}/lib/manual-link)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/qtmain.lib)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/qtmain.prl)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/qtmaind.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
        file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/qtmaind.prl DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/qtmaind.lib)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/qtmaind.prl)
    endif()

    #---------------------------------------------------------------------------
    # Qt5Bootstrap: only used to bootstrap qmake dependencies
    #---------------------------------------------------------------------------
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/Qt5Bootstrap.lib)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/Qt5Bootstrap.prl)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/Qt5Bootstrap.lib ${CURRENT_PACKAGES_DIR}/tools/qt5/Qt5Bootstrap.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/Qt5Bootstrap.prl ${CURRENT_PACKAGES_DIR}/tools/qt5/Qt5Bootstrap.prl)
    endif()
    #---------------------------------------------------------------------------
endif()

file(GLOB_RECURSE PRL_FILES "${CURRENT_PACKAGES_DIR}/lib/*.prl" "${CURRENT_PACKAGES_DIR}/debug/lib/*.prl")
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(TO_CMAKE_PATH "${VCPKG_RELEASE_LIBDIR}" CMAKE_RELEASE_LIB_PATH)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(TO_CMAKE_PATH "${VCPKG_DEBUG_LIBDIR}" CMAKE_DEBUG_LIB_PATH)
endif()
foreach(PRL_FILE IN LISTS PRL_FILES)
    file(READ "${PRL_FILE}" _contents)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        string(REPLACE "${CMAKE_RELEASE_LIB_PATH}" "\$\$[QT_INSTALL_LIBS]" _contents "${_contents}")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        string(REPLACE "${CMAKE_DEBUG_LIB_PATH}" "\$\$[QT_INSTALL_LIBS]" _contents "${_contents}")
    endif()
    file(WRITE "${PRL_FILE}" "${_contents}")
endforeach()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/qtdeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/plugins)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/qtdeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/debug/plugins)
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/qt5core)

file(INSTALL ${SOURCE_PATH}/LICENSE.LGPLv3 DESTINATION  ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
#
