string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
if(BUILDTREES_PATH_LENGTH GREATER 37 AND CMAKE_HOST_WIN32)
    message(WARNING "${PORT}'s buildsystem uses very long paths and may fail on your system.\n"
        "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
    )
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(configure_qt)
include(install_qt)

set(MAJOR_MINOR 5.12)
set(FULL_VERSION ${MAJOR_MINOR}.4)
set(ARCHIVE_NAME "qtbase-everywhere-src-${FULL_VERSION}.tar.xz")

vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://download.qt.io/official_releases/qt/${MAJOR_MINOR}/${FULL_VERSION}/submodules/${ARCHIVE_NAME}"
    FILENAME ${ARCHIVE_NAME}
    SHA512 28b029a0d3621477f625d474b8bc38ddcc7173df6adb274b438e290b6c50bd0891e5b62c04b566a281781acee3a353a6a3b0bc88228e996994f92900448d7946
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE_FILE}"
    REF ${FULL_VERSION}
    PATCHES
        winmain_pro.patch   #Moves qtmain to manual-link
        windows_prf.patch   #fixes the qtmain dependency due to the above move
#        bootstrap_pro.patch #Moves location of bootstrap to tools/qt5 since it is only used to bootstrap qmake dependencies
#        qt_app.patch       #Moves the target location of qt5 tools from bin to tools/qt5
)

# Remove vendored dependencies to ensure they are not picked up by the build
#foreach(DEPENDENCY freetype zlib harfbuzzng libjpeg libpng double-conversion sqlite)
#    if(EXISTS ${SOURCE_PATH}/src/3rdparty/${DEPENDENCY})
#        file(REMOVE_RECURSE ${SOURCE_PATH}/src/3rdparty/${DEPENDENCY})
#    endif()
#endforeach()

#file(REMOVE_RECURSE ${SOURCE_PATH}/include/QtZlib)

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
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    set(PLATFORM "win32-msvc")

    configure_qt(
        SOURCE_PATH ${SOURCE_PATH}
        PLATFORM ${PLATFORM}
        OPTIONS
            ${CORE_OPTIONS}
            -mp
            -opengl dynamic # other options are "-no-opengl", "-opengl angle", and "-opengl desktop"
        OPTIONS_RELEASE
            LIBJPEG_LIBS="-ljpeg"
            ZLIB_LIBS="-lzlib"
            LIBPNG_LIBS="-llibpng16"
            PSQL_LIBS="-llibpq"
            PCRE2_LIBS="-lpcre2-16"
            FREETYPE_LIBS="-lfreetype"
        OPTIONS_DEBUG
            LIBJPEG_LIBS="-ljpegd"
            ZLIB_LIBS="-lzlibd"
            LIBPNG_LIBS="-llibpng16d"
            PSQL_LIBS="-llibpqd"
            PCRE2_LIBS="-lpcre2-16d"
            FREETYPE_LIBS="-lfreetyped"
    )
    
elseif(VCPKG_TARGET_IS_LINUX)
    if (NOT EXISTS "/usr/include/GL/glu.h")
        message(FATAL_ERROR "qt5 requires libgl1-mesa-dev and libglu1-mesa-dev, please use your distribution's package manager to install them.\nExample: \"apt-get install libgl1-mesa-dev\" and \"apt-get install libglu1-mesa-dev\"")
    endif()

    configure_qt(
        SOURCE_PATH ${SOURCE_PATH}
        PLATFORM "linux-g++"
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
    PLATFORM "macx-clang"
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

#TODO: PATCH QTs buildsystem so that all binary targets get installed in tools/qt5
# e.g. by patching mkspecs/features/qt_tools.prf somehow
file(GLOB_RECURSE PRL_FILES "${CURRENT_PACKAGES_DIR}/lib/*.prl" "${CURRENT_PACKAGES_DIR}/tools/qt5/*.prl" "${CURRENT_PACKAGES_DIR}/debug/lib/*.prl" "${CURRENT_PACKAGES_DIR}/debug/tools/qt5/*.prl")

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
#    file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*")
#    list(FILTER BINARY_TOOLS EXCLUDE REGEX "\\.dll\$")
#    file(INSTALL ${BINARY_TOOLS}
#        PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
#         DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qt5)
#    file(REMOVE ${BINARY_TOOLS})
#
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/qt_release.conf DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qt5) #TODO: Use and fix the one generated by configure qt
    file(TO_CMAKE_PATH "${CURRENT_INSTALLED_DIR}/lib" CMAKE_RELEASE_LIB_PATH)
    foreach(PRL_FILE IN LISTS PRL_FILES)
        file(READ "${PRL_FILE}" _contents)
        string(REPLACE "${CMAKE_RELEASE_LIB_PATH}" "\$\$[QT_INSTALL_LIBS]" _contents "${_contents}")
        file(WRITE "${PRL_FILE}" "${_contents}")
    endforeach()
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/qtdeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/plugins)
    #if(VCPKG_TARGET_IS_WINDOWS)
       # file(APPEND ${CURRENT_PACKAGES_DIR}/share/qt5/mkspecs/modules/qt_lib_bootstrap_private.pri "LIBS += -luser32 -lole32 -ladvapi32 -lshell32 -lnetapi32 -lzlib")
    #else()
       # file(APPEND ${CURRENT_PACKAGES_DIR}/share/qt5/mkspecs/modules/qt_lib_bootstrap_private.pri "LIBS += -lz")
    #endif()
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
#    file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/debug/bin/*")
#    list(FILTER BINARY_TOOLS EXCLUDE REGEX "\\.dll\$")
#    file(REMOVE ${BINARY_TOOLS})
#    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
#        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
#    endif()

    file(COPY ${CMAKE_CURRENT_LIST_DIR}/qt_debug.conf DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qt5) #TODO: Use and fix the one generated by configure qt
    file(TO_CMAKE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib" CMAKE_DEBUG_LIB_PATH)
    foreach(PRL_FILE IN LISTS PRL_FILES)
        file(READ "${PRL_FILE}" _contents)
        string(REPLACE "${CMAKE_DEBUG_LIB_PATH}" "\$\$[QT_INSTALL_LIBS]" _contents "${_contents}")
        file(WRITE "${PRL_FILE}" "${_contents}")
    endforeach()
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/qtdeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/debug/plugins)
    #if(VCPKG_TARGET_IS_WINDOWS)
       # file(APPEND ${CURRENT_PACKAGES_DIR}/share/qt5/debug/mkspecs/modules/qt_lib_bootstrap_private.pri "LIBS += -luser32 -lole32 -ladvapi32 -lshell32 -lnetapi32 -lzlibd")
    #else()
       # file(APPEND ${CURRENT_PACKAGES_DIR}/share/qt5/debug/mkspecs/modules/qt_lib_bootstrap_private.pri "LIBS += -lz")
    #endif()
endif()

file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake) # TODO: check if important debug information for cmake is lost 
#TODO: Replace python script with cmake script

vcpkg_execute_required_process(
    COMMAND ${PYTHON3} ${CMAKE_CURRENT_LIST_DIR}/fixcmake.py
    WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/cmake
    LOGNAME fix-cmake
)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/qt5)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/qt5core)

file(INSTALL ${SOURCE_PATH}/LICENSE.LGPLv3 DESTINATION  ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
#
