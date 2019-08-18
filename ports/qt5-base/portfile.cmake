
vcpkg_find_qt_platforms(TARGET_MKSPEC HOST_MKSPEC HOST_TOOLS)

string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
if(BUILDTREES_PATH_LENGTH GREATER 37 AND CMAKE_HOST_WIN32)
    message(WARNING "${PORT}'s buildsystem uses very long paths and may fail on your system.\n"
        "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
    )
endif()

set(QT_PLATFORM_CONFIGURE_OPTIONS TARGET_PLATFORM ${TARGET_MKSPEC})
if(DEFINED HOST_MKSPEC)
    list(APPEND QT_PLATFORM_CONFIGURE_OPTIONS HOST_PLATFORM ${HOST_MKSPEC})
endif()
if(DEFINED HOST_TOOLS)
    list(APPEND QT_PLATFORM_CONFIGURE_OPTIONS HOST_TOOLS_ROOT ${HOST_TOOLS})
endif()
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

include(qt_port_hashes)
include(configure_qt)
include(install_qt)

set(FULL_VERSION "${QT_MAJOR_MINOR_VER}.${QT_PATCH_VER}")
set(ARCHIVE_NAME "qtbase-everywhere-src-${FULL_VERSION}.tar.xz")

vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://download.qt.io/official_releases/qt/${MAJOR_MINOR}/${FULL_VERSION}/submodules/${ARCHIVE_NAME}"
    FILENAME ${ARCHIVE_NAME}
    SHA512 ${QT_HASH_${PORT}}
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE_FILE}"
    REF ${FULL_VERSION}
    PATCHES
        winmain_pro.patch   #Moves qtmain to manual-link
        windows_prf.patch   #fixes the qtmain dependency due to the above move
        qt_app.patch        #Moves the target location of qt5 host apps to always install into the host dir. 
        gui_configure.patch #Patches the gui configure.json to include the correct fonttype dependencies
        static_opengl.patch #Let the Khronos headers define the required preprocessor definitions. Qt5 you know nothing. 
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
    -system-freetype # static builds require to also link its dependent bzip!
    -system-pcre
    -system-doubleconversion
    -system-sqlite
    -system-harfbuzz
    #-no-fontconfig
    -nomake examples
    -nomake tests
    #-simulator_and_device
    #-ltcg
    #-combined-angle-lib
)

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_IS_UWP)
        list(APPEND CORE_OPTIONS -appstore-compliant)
    endif()
    if(NOT ${VCPKG_LIBRARY_LINKAGE} STREQUAL "static")
        list(APPEND CORE_OPTIONS -opengl dynamic) # other options are "-no-opengl", "-opengl angle", and "-opengl desktop" and "-opengeles2"
    else()
        list(APPEND CORE_OPTIONS -opengl es2) # dynamic will generate angle dll and the angle port has been explicitly deleted. 
                                              # es2 is the Windows automatic default. (might make problems with older qt projects due to including angle.)
                                              # use QT -= core gui if that happens or we need to switch this one to desktop
    endif()
    configure_qt(
        SOURCE_PATH ${SOURCE_PATH}
        ${QT_PLATFORM_CONFIGURE_OPTIONS}
        OPTIONS
            ${CORE_OPTIONS}
            -mp
        OPTIONS_RELEASE
            "LIBJPEG_LIBS=-ljpeg"
            "ZLIB_LIBS=-lzlib"
            "LIBPNG_LIBS=-llibpng16"
            "PSQL_LIBS=-llibpq"
            "PCRE2_LIBS=-lpcre2-16"
            "FREETYPE_LIBS=${CURRENT_INSTALLED_DIR}/lib/freetype.lib ${CURRENT_INSTALLED_DIR}/lib/bz2.lib ${CURRENT_INSTALLED_DIR}/lib/libpng16.lib" # for some strange reason the -l version is not extended in the generated files. 
            "QMAKE_LIBS_PRIVATE+=${CURRENT_INSTALLED_DIR}/lib/bz2.lib"
            "QMAKE_LIBS_PRIVATE+=${CURRENT_INSTALLED_DIR}/lib/libpng16.lib"
        OPTIONS_DEBUG
            "LIBJPEG_LIBS=-ljpegd"
            "ZLIB_LIBS=-lzlibd"
            "LIBPNG_LIBS=-llibpng16d"
            "PSQL_LIBS=-llibpqd"
            "PCRE2_LIBS=-lpcre2-16d"
            "FREETYPE_LIBS=-lfreetyped -lbz2d -llibpng16d"
            "QMAKE_LIBS_PRIVATE+=${CURRENT_INSTALLED_DIR}/debug/lib/bz2d.lib"
            "QMAKE_LIBS_PRIVATE+=${CURRENT_INSTALLED_DIR}/debug/lib/libpng16d.lib"
            )    
elseif(VCPKG_TARGET_IS_LINUX)
    if (NOT EXISTS "/usr/include/GL/glu.h")
        message(FATAL_ERROR "qt5 requires libgl1-mesa-dev and libglu1-mesa-dev, please use your distribution's package manager to install them.\nExample: \"apt-get install libgl1-mesa-dev libglu1-mesa-dev\"")
    endif()

    configure_qt(
        SOURCE_PATH ${SOURCE_PATH}
        ${QT_PLATFORM_CONFIGURE_OPTIONS}
        OPTIONS
            ${CORE_OPTIONS}
        OPTIONS_RELEASE
            "LIBJPEG_LIBS=${CURRENT_INSTALLED_DIR}/lib/libjpeg.a"
            "QMAKE_LIBS_PRIVATE+=${CURRENT_INSTALLED_DIR}/lib/libpng16.a"
            "QMAKE_LIBS_PRIVATE+=${CURRENT_INSTALLED_DIR}/lib/libz.a"
            "ZLIB_LIBS=${CURRENT_INSTALLED_DIR}/lib/libz.a"
            "LIBPNG_LIBS=${CURRENT_INSTALLED_DIR}/lib/libpng16.a"
            "FREETYPE_LIBS=${CURRENT_INSTALLED_DIR}/lib/libfreetype.a"
            "PSQL_LIBS=${CURRENT_INSTALLED_DIR}/lib/libpq.a ${CURRENT_INSTALLED_DIR}/lib/libssl.a ${CURRENT_INSTALLED_DIR}/lib/libcrypto.a -ldl -lpthread"
            "SQLITE_LIBS=${CURRENT_INSTALLED_DIR}/lib/libsqlite3.a -ldl -lpthread"
        OPTIONS_DEBUG
            "LIBJPEG_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libjpeg.a"
            "QMAKE_LIBS_PRIVATE+=${CURRENT_INSTALLED_DIR}/debug/lib/libpng16d.a"
            "QMAKE_LIBS_PRIVATE+=${CURRENT_INSTALLED_DIR}/debug/lib/libz.a"
            "ZLIB_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libz.a"
            "LIBPNG_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libpng16d.a"
            "FREETYPE_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libfreetyped.a"
            "PSQL_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libpqd.a ${CURRENT_INSTALLED_DIR}/debug/lib/libssl.a ${CURRENT_INSTALLED_DIR}/debug/lib/libcrypto.a -ldl -lpthread"
            "SQLITE_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libsqlite3.a -ldl -lpthread"
    )
elseif(VCPKG_TARGET_IS_OSX)
    configure_qt(
        SOURCE_PATH ${SOURCE_PATH}
        ${QT_PLATFORM_CONFIGURE_OPTIONS}
        OPTIONS
            ${CORE_OPTIONS}
        OPTIONS_RELEASE
            "LIBJPEG_LIBS=${CURRENT_INSTALLED_DIR}/lib/libjpeg.a"
            "QMAKE_LIBS_PRIVATE+=${CURRENT_INSTALLED_DIR}/lib/libpng16.a"
            "QMAKE_LIBS_PRIVATE+=${CURRENT_INSTALLED_DIR}/lib/libz.a"
            "ZLIB_LIBS=${CURRENT_INSTALLED_DIR}/lib/libz.a"
            "LIBPNG_LIBS=${CURRENT_INSTALLED_DIR}/lib/libpng16.a"
            "FREETYPE_LIBS=${CURRENT_INSTALLED_DIR}/lib/libfreetype.a"
            "PSQL_LIBS=${CURRENT_INSTALLED_DIR}/lib/libpq.a ${CURRENT_INSTALLED_DIR}/lib/libssl.a ${CURRENT_INSTALLED_DIR}/lib/libcrypto.a -ldl -lpthread"
            "SQLITE_LIBS=${CURRENT_INSTALLED_DIR}/lib/libsqlite3.a -ldl -lpthread"
            "HARFBUZZ_LIBS=${CURRENT_INSTALLED_DIR}/lib/libharfbuzz.a -framework ApplicationServices"
        OPTIONS_DEBUG
            "LIBJPEG_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libjpeg.a"
            "QMAKE_LIBS_PRIVATE+=${CURRENT_INSTALLED_DIR}/debug/lib/libpng16d.a"
            "QMAKE_LIBS_PRIVATE+=${CURRENT_INSTALLED_DIR}/debug/lib/libz.a"
            "ZLIB_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libz.a"
            "LIBPNG_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libpng16d.a"
            "FREETYPE_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libfreetyped.a"
            "PSQL_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libpqd.a ${CURRENT_INSTALLED_DIR}/debug/lib/libssl.a ${CURRENT_INSTALLED_DIR}/debug/lib/libcrypto.a -ldl -lpthread"
            "SQLITE_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libsqlite3.a -ldl -lpthread"
            "HARFBUZZ_LIBS=${CURRENT_INSTALLED_DIR}/debug/lib/libharfbuzz.a -framework ApplicationServices"
    )
endif()

if(VCPKG_TARGET_IS_OSX)
    install_qt(DISABLE_PARALLEL) # prevent race condition on Mac
else()
    install_qt()
endif()

#TODO: Make this a function since it is also done by modular scripts!
# e.g. by patching mkspecs/features/qt_tools.prf somehow
file(GLOB_RECURSE PRL_FILES "${CURRENT_PACKAGES_DIR}/lib/*.prl" "${CURRENT_PACKAGES_DIR}/tools/qt5/lib/*.prl" "${CURRENT_PACKAGES_DIR}/tools/qt5/mkspecs/*.pri" 
                            "${CURRENT_PACKAGES_DIR}/debug/lib/*.prl" "${CURRENT_PACKAGES_DIR}/tools/qt5/debug/lib/*.prl" "${CURRENT_PACKAGES_DIR}/tools/qt5/debug/mkspecs/*.pri")

file(TO_CMAKE_PATH "${CURRENT_INSTALLED_DIR}/include" CMAKE_INCLUDE_PATH)

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(TO_CMAKE_PATH "${CURRENT_INSTALLED_DIR}/lib" CMAKE_RELEASE_LIB_PATH)
    foreach(PRL_FILE IN LISTS PRL_FILES)
        file(READ "${PRL_FILE}" _contents)
        string(REPLACE "${CMAKE_RELEASE_LIB_PATH}" "\$\$[QT_INSTALL_LIBS]" _contents "${_contents}")
        string(REPLACE "${CMAKE_INCLUDE_PATH}" "\$\$[QT_INSTALL_HEADERS]" _contents "${_contents}")
        file(WRITE "${PRL_FILE}" "${_contents}")
    endforeach()
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/qtdeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/plugins)
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(TO_CMAKE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib" CMAKE_DEBUG_LIB_PATH)
    foreach(PRL_FILE IN LISTS PRL_FILES)
        file(READ "${PRL_FILE}" _contents)
        string(REPLACE "${CMAKE_DEBUG_LIB_PATH}" "\$\$[QT_INSTALL_LIBS]" _contents "${_contents}")
        string(REPLACE "${CMAKE_INCLUDE_PATH}" "\$\$[QT_INSTALL_HEADERS]" _contents "${_contents}")
        file(WRITE "${PRL_FILE}" "${_contents}")
    endforeach()
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/qtdeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/debug/plugins)
endif()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake) # TODO: check if important debug information for cmake is lost 

#TODO: Replace python script with cmake script
vcpkg_execute_required_process(
    COMMAND ${PYTHON3} ${CMAKE_CURRENT_LIST_DIR}/fixcmake.py
    WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/cmake
    LOGNAME fix-cmake
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/qt5core)

file(INSTALL ${SOURCE_PATH}/LICENSE.LGPLv3 DESTINATION  ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

#install scripts for other qt ports
file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/fixcmake.py
    ${CMAKE_CURRENT_LIST_DIR}/qt_ports_helper.cmake
    ${CMAKE_CURRENT_LIST_DIR}/qt_port_hashes.cmake
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/share/qt5
)
#
