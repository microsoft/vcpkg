vcpkg_buildpath_length_warning(37)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    option(QT_OPENSSL_LINK "Link against OpenSSL at compile-time." ON)
else()
    option(QT_OPENSSL_LINK "Link against OpenSSL at compile-time." OFF)
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

if("latest" IN_LIST FEATURES)
  set(QT_BUILD_LATEST ON)
endif()

include(qt_port_functions)
include(configure_qt)
include(install_qt)

#########################
## Find Host and Target mkspec name for configure
include(find_qt_mkspec)
find_qt_mkspec(TARGET_MKSPEC HOST_MKSPEC HOST_TOOLS)
set(QT_PLATFORM_CONFIGURE_OPTIONS TARGET_PLATFORM ${TARGET_MKSPEC})
if(DEFINED HOST_MKSPEC)
    list(APPEND QT_PLATFORM_CONFIGURE_OPTIONS HOST_PLATFORM ${HOST_MKSPEC})
endif()
if(DEFINED HOST_TOOLS)
    list(APPEND QT_PLATFORM_CONFIGURE_OPTIONS HOST_TOOLS_ROOT ${HOST_TOOLS})
endif()

#########################
## Downloading Qt5-Base

qt_download_submodule(  OUT_SOURCE_PATH SOURCE_PATH
                        PATCHES
                            patches/winmain_pro.patch   #Moves qtmain to manual-link
                            patches/windows_prf.patch   #fixes the qtmain dependency due to the above move
                            patches/qt_app.patch        #Moves the target location of qt5 host apps to always install into the host dir. 
                            patches/gui_configure.patch #Patches the gui configure.json to break freetype/fontconfig autodetection because it does not include its dependencies.
                            #patches/static_opengl.patch #Use this patch if you really want to statically link angle on windows (e.g. using -opengl es2 and -static). 
                                                         #Be carefull since it requires definining _GDI32_ for all dependent projects due to redefinition errors in the 
                                                         #the windows supplied gl.h header and the angle gl.h otherwise. 
                    )

# Remove vendored dependencies to ensure they are not picked up by the build
foreach(DEPENDENCY freetype zlib harfbuzz-ng libjpeg libpng double-conversion sqlite pcre2)
    if(EXISTS ${SOURCE_PATH}/src/3rdparty/${DEPENDENCY})
        file(REMOVE_RECURSE ${SOURCE_PATH}/src/3rdparty/${DEPENDENCY})
    endif()
endforeach()
file(REMOVE_RECURSE ${SOURCE_PATH}/include/QtZlib)

#########################
## Setup Configure options

# This fixes issues on machines with default codepages that are not ASCII compatible, such as some CJK encodings
set(ENV{_CL_} "/utf-8")

set(CORE_OPTIONS
    -confirm-license
    -opensource
    #-no-fontconfig
    #-simulator_and_device
    #-ltcg
    #-combined-angle-lib 
    # ENV ANGLE_DIR to external angle source dir. (Will always be compiled with Qt)
    #-optimized-tools
    #-force-debug-info
    -verbose
)

## 3rd Party Libs
list(APPEND CORE_OPTIONS
    -system-zlib
    -system-libjpeg
    -system-libpng
    -system-freetype # static builds require to also link its dependent bzip!
    -system-pcre
    -system-doubleconversion
    -system-sqlite
    -system-harfbuzz
    -no-angle)      # Qt does not need to build angle. VCPKG will build angle!

if(QT_OPENSSL_LINK)
    list(APPEND CORE_OPTIONS -openssl-linked)
endif()

find_library(ZLIB_RELEASE NAMES z zlib PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(ZLIB_DEBUG NAMES z zlib zd zlibd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(JPEG_RELEASE NAMES jpeg jpeg-static PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(JPEG_DEBUG NAMES jpeg jpeg-static jpegd jpeg-staticd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(LIBPNG_RELEASE NAMES png16 libpng16 PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH) #Depends on zlib
find_library(LIBPNG_DEBUG NAMES png16 png16d libpng16 libpng16d PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(PSQL_RELEASE NAMES pq libpq PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH) # Depends on openssl and zlib(linux)
find_library(PSQL_DEBUG NAMES pq libpq pqd libpqd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(PCRE2_RELEASE NAMES pcre2-16 PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(PCRE2_DEBUG NAMES pcre2-16 pcre2-16d PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(FREETYPE_RELEASE NAMES freetype PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH) #zlib, bzip2, libpng
find_library(FREETYPE_DEBUG NAMES freetype freetyped PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(DOUBLECONVERSION_RELEASE NAMES double-conversion PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH) 
find_library(DOUBLECONVERSION_DEBUG NAMES double-conversion PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(HARFBUZZ_RELEASE NAMES harfbuzz PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH) 
find_library(HARFBUZZ_DEBUG NAMES harfbuzz PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(SQLITE_RELEASE NAMES sqlite3 PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH) # Depends on openssl and zlib(linux)
find_library(SQLITE_DEBUG NAMES sqlite3 sqlite3d PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)

find_library(ICUUC_RELEASE NAMES icuuc libicuuc PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(ICUUC_DEBUG NAMES icuucd libicuucd iccuc libicuuc PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(ICUTU_RELEASE NAMES icutu libicutu PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(ICUTU_DEBUG NAMES icutud libicutud iccutu libicutu PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(ICULX_RELEASE NAMES iculx libiculx PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(ICULX_DEBUG NAMES iculxd libiculxd icculx libiculx PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(ICUIO_RELEASE NAMES icuio libicuio PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(ICUIO_DEBUG NAMES icuiod libicuiod iccuio libicuio PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(ICUIN_RELEASE NAMES icui18n libicui18n PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(ICUIN_DEBUG NAMES icui18nd libicui18nd iccui18n libicui18n PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(ICUDATA_RELEASE NAMES icudata libicudata PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(ICUDATA_DEBUG NAMES icudatad libicudatad iccudata libicudata PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
set(ICU_RELEASE "${ICUUC_RELEASE} ${ICUTU_RELEASE} ${ICULX_RELEASE} ${ICUIO_RELEASE} ${ICUIN_RELEASE} ${ICUDATA_RELEASE}")
set(ICU_DEBUG "${ICUUC_DEBUG} ${ICUTU_DEBUG} ${ICULX_DEBUG} ${ICUIO_DEBUG} ${ICUIN_DEBUG} ${ICUDATA_DEBUG}")

find_library(FONTCONFIG_RELEASE NAMES fontconfig PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(FONTCONFIG_DEBUG NAMES fontconfig PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(EXPAT_RELEASE NAMES expat PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(EXPAT_DEBUG NAMES expat PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)

#Dependent libraries
find_library(BZ2_RELEASE bz2 PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(BZ2_DEBUG bz2 bz2d PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(SSL_RELEASE ssl ssleay32 PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(SSL_DEBUG ssl ssleay32 ssld ssleay32d PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(EAY_RELEASE libeay32 crypto libcrypto PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(EAY_DEBUG libeay32 crypto libcrypto libeay32d cryptod libcryptod PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)

set(RELEASE_OPTIONS
            "LIBJPEG_LIBS=${JPEG_RELEASE}"
            "ZLIB_LIBS=${ZLIB_RELEASE}"
            "LIBPNG_LIBS=${LIBPNG_RELEASE} ${ZLIB_RELEASE}"
            "PCRE2_LIBS=${PCRE2_RELEASE}"
            "FREETYPE_LIBS=${FREETYPE_RELEASE} ${BZ2_RELEASE} ${LIBPNG_RELEASE} ${ZLIB_RELEASE}"
            "ICU_LIBS=${ICU_RELEASE}"
            "QMAKE_LIBS_PRIVATE+=${BZ2_RELEASE}"
            "QMAKE_LIBS_PRIVATE+=${LIBPNG_RELEASE}"            
            )
set(DEBUG_OPTIONS
            "LIBJPEG_LIBS=${JPEG_DEBUG}"
            "ZLIB_LIBS=${ZLIB_DEBUG}"
            "LIBPNG_LIBS=${LIBPNG_DEBUG} ${ZLIB_DEBUG}"
            "PCRE2_LIBS=${PCRE2_DEBUG}"
            "FREETYPE_LIBS=${FREETYPE_DEBUG} ${BZ2_DEBUG} ${LIBPNG_DEBUG} ${ZLIB_DEBUG}"
            "ICU_LIBS=${ICU_DEBUG}"
            "QMAKE_LIBS_PRIVATE+=${BZ2_DEBUG}"
            "QMAKE_LIBS_PRIVATE+=${LIBPNG_DEBUG}"
            )


if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_IS_UWP)
        list(APPEND CORE_OPTIONS -appstore-compliant)
    endif()
    if(NOT ${VCPKG_LIBRARY_LINKAGE} STREQUAL "static")
        list(APPEND CORE_OPTIONS -opengl dynamic) # other options are "-no-opengl", "-opengl angle", and "-opengl desktop" and "-opengel es2"
    else()
        list(APPEND CORE_OPTIONS -opengl dynamic) # other possible option without moving angle dlls: "-opengl desktop". "-opengel es2" only works with commented patch 
    endif()
    list(APPEND RELEASE_OPTIONS
            "PSQL_LIBS=${PSQL_RELEASE} ${SSL_RELEASE} ${EAY_RELEASE} ws2_32.lib secur32.lib advapi32.lib shell32.lib crypt32.lib user32.lib gdi32.lib"
            "SQLITE_LIBS=${SQLITE_RELEASE}"
            "HARFBUZZ_LIBS=${HARFBUZZ_RELEASE}"
            "OPENSSL_LIBS=${SSL_RELEASE} ${EAY_RELEASE} ws2_32.lib secur32.lib advapi32.lib shell32.lib crypt32.lib user32.lib gdi32.lib"
        )
        
    list(APPEND DEBUG_OPTIONS
            "PSQL_LIBS=${PSQL_DEBUG} ${SSL_DEBUG} ${EAY_DEBUG} ws2_32.lib secur32.lib advapi32.lib shell32.lib crypt32.lib user32.lib gdi32.lib"
            "SQLITE_LIBS=${SQLITE_DEBUG}"
            "HARFBUZZ_LIBS=${HARFBUZZ_DEBUG}"
            "OPENSSL_LIBS=${SSL_DEBUG} ${EAY_DEBUG} ws2_32.lib secur32.lib advapi32.lib shell32.lib crypt32.lib user32.lib gdi32.lib"
        )
elseif(VCPKG_TARGET_IS_LINUX)
    list(APPEND CORE_OPTIONS -fontconfig)
    if (NOT EXISTS "/usr/include/GL/glu.h")
        message(FATAL_ERROR "qt5 requires libgl1-mesa-dev and libglu1-mesa-dev, please use your distribution's package manager to install them.\nExample: \"apt-get install libgl1-mesa-dev libglu1-mesa-dev\"")
    endif()
    list(APPEND RELEASE_OPTIONS
            "PSQL_LIBS=${PSQL_RELEASE} ${SSL_RELEASE} ${EAY_RELEASE} -ldl -lpthread"
            "SQLITE_LIBS=${SQLITE_RELEASE} -ldl -lpthread"
            "HARFBUZZ_LIBS=${HARFBUZZ_RELEASE}"
            "OPENSSL_LIBS=${SSL_RELEASE} ${EAY_RELEASE} -ldl -lpthread"
            "FONTCONFIG_LIBS=${FONTCONFIG_RELEASE} ${FREETYPE_RELEASE} ${EXPAT_RELEASE}"
        )
    list(APPEND DEBUG_OPTIONS
            "PSQL_LIBS=${PSQL_DEBUG} ${SSL_DEBUG} ${EAY_DEBUG} -ldl -lpthread"
            "SQLITE_LIBS=${SQLITE_DEBUG} -ldl -lpthread"
            "HARFBUZZ_LIBS=${HARFBUZZ_DEBUG}"
            "OPENSSL_LIBS=${SSL_DEBUG} ${EAY_DEBUG} -ldl -lpthread"
            "FONTCONFIG_LIBS=${FONTCONFIG_DEBUG} ${FREETYPE_DEBUG} ${EXPAT_DEBUG}"
        )
elseif(VCPKG_TARGET_IS_OSX)
    list(APPEND CORE_OPTIONS -fontconfig)
    if(DEFINED VCPKG_OSX_DEPLOYMENT_TARGET)
        set(ENV{QMAKE_MACOSX_DEPLOYMENT_TARGET} ${VCPKG_OSX_DEPLOYMENT_TARGET})
    else()
        execute_process(COMMAND xcrun --show-sdk-version
                            OUTPUT_FILE OSX_SDK_VER.txt
                            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR})
        FILE(STRINGS "${CURRENT_BUILDTREES_DIR}/OSX_SDK_VER.txt" VCPKG_OSX_DEPLOYMENT_TARGET REGEX "^[0-9][0-9]\.[0-9][0-9]*")
        message(STATUS "Detected OSX SDK Version: ${VCPKG_OSX_DEPLOYMENT_TARGET}")
        string(REGEX MATCH "^[0-9][0-9]\.[0-9][0-9]*" VCPKG_OSX_DEPLOYMENT_TARGET ${VCPKG_OSX_DEPLOYMENT_TARGET})
        message(STATUS "Major.Minor OSX SDK Version: ${VCPKG_OSX_DEPLOYMENT_TARGET}")
        set(ENV{QMAKE_MACOSX_DEPLOYMENT_TARGET} ${VCPKG_OSX_DEPLOYMENT_TARGET})
        if(${VCPKG_OSX_DEPLOYMENT_TARGET} GREATER "10.15") # Max Version supported by QT. This version is defined in mkspecs/common/macx.conf as QT_MAC_SDK_VERSION_MAX
            message(STATUS "Qt ${QT_MAJOR_MINOR_VER}.${QT_PATCH_VER} only support OSX_DEPLOYMENT_TARGET up to 10.15")
            set(VCPKG_OSX_DEPLOYMENT_TARGET "10.15")
        endif()
        set(ENV{QMAKE_MACOSX_DEPLOYMENT_TARGET} ${VCPKG_OSX_DEPLOYMENT_TARGET})
        message(STATUS "Enviromnent OSX SDK Version: $ENV{QMAKE_MACOSX_DEPLOYMENT_TARGET}")
        FILE(READ "${SOURCE_PATH}/mkspecs/common/macx.conf" _tmp_contents)
        string(REPLACE "QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.12" "QMAKE_MACOSX_DEPLOYMENT_TARGET = ${VCPKG_OSX_DEPLOYMENT_TARGET}" _tmp_contents ${_tmp_contents})
        FILE(WRITE "${SOURCE_PATH}/mkspecs/common/macx.conf" ${_tmp_contents})
    endif()
    #list(APPEND QT_PLATFORM_CONFIGURE_OPTIONS HOST_PLATFORM ${TARGET_MKSPEC})
    list(APPEND RELEASE_OPTIONS
            "PSQL_LIBS=${PSQL_RELEASE} ${SSL_RELEASE} ${EAY_RELEASE} -ldl -lpthread"
            "SQLITE_LIBS=${SQLITE_RELEASE} -ldl -lpthread"
            "HARFBUZZ_LIBS=${HARFBUZZ_RELEASE} -framework ApplicationServices"
            "OPENSSL_LIBS=${SSL_RELEASE} ${EAY_RELEASE} -ldl -lpthread"
            "FONTCONFIG_LIBS=${FONTCONFIG_RELEASE} ${FREETYPE_RELEASE} ${EXPAT_RELEASE}"
        )
    list(APPEND DEBUG_OPTIONS
            "PSQL_LIBS=${PSQL_DEBUG} ${SSL_DEBUG} ${EAY_DEBUG} -ldl -lpthread"
            "SQLITE_LIBS=${SQLITE_DEBUG} -ldl -lpthread"
            "HARFBUZZ_LIBS=${HARFBUZZ_DEBUG} -framework ApplicationServices"
            "OPENSSL_LIBS=${SSL_DEBUG} ${EAY_DEBUG} -ldl -lpthread"
            "FONTCONFIG_LIBS=${FONTCONFIG_DEBUG} ${FREETYPE_DEBUG} ${EXPAT_DEBUG}"
        )
endif()

## Do not build tests or examples
list(APPEND CORE_OPTIONS
    -nomake examples
    -nomake tests)

if(QT_UPDATE_VERSION)
    SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()
    configure_qt(
        SOURCE_PATH ${SOURCE_PATH}
        ${QT_PLATFORM_CONFIGURE_OPTIONS}
        OPTIONS ${CORE_OPTIONS}
        OPTIONS_RELEASE ${RELEASE_OPTIONS}
        OPTIONS_DEBUG ${DEBUG_OPTIONS}
        )

    install_qt()

    #########################
    #TODO: Make this a function since it is also done by modular scripts!
    # e.g. by patching mkspecs/features/qt_tools.prf somehow
    file(GLOB_RECURSE PRL_FILES "${CURRENT_PACKAGES_DIR}/lib/*.prl" "${CURRENT_PACKAGES_DIR}/tools/qt5/lib/*.prl" "${CURRENT_PACKAGES_DIR}/tools/qt5/mkspecs/*.pri" 
                                "${CURRENT_PACKAGES_DIR}/debug/lib/*.prl" "${CURRENT_PACKAGES_DIR}/tools/qt5/debug/lib/*.prl" "${CURRENT_PACKAGES_DIR}/tools/qt5/debug/mkspecs/*.pri")

    file(TO_CMAKE_PATH "${CURRENT_INSTALLED_DIR}/include" CMAKE_INCLUDE_PATH)

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        qt_fix_prl("${CURRENT_INSTALLED_DIR}" "${PRL_FILES}")
        file(COPY ${CMAKE_CURRENT_LIST_DIR}/qtdeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/plugins)
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        qt_fix_prl("${CURRENT_INSTALLED_DIR}/debug" "${PRL_FILES}")
        file(COPY ${CMAKE_CURRENT_LIST_DIR}/qtdeploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/debug/plugins)
    endif()

    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/cmake)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake) # TODO: check if important debug information for cmake is lost 

    #This needs a new VCPKG policy. 
    if(VCPKG_TARGET_IS_WINDOWS AND ${VCPKG_LIBRARY_LINKAGE} MATCHES "static") # Move angle dll libraries 
        message(STATUS "Moving ANGLE dlls from /bin to /tools/qt5-angle/bin. In static builds dlls are not allowed in /bin")
        if(EXISTS "${CURRENT_PACKAGES_DIR}/bin")
            file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/qt5-angle)
            file(RENAME ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/tools/qt5-angle/bin)
            if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/bin)
                file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/qt5-angle/debug)
                file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/tools/qt5-angle/debug/bin)
            endif()
        endif()
    endif()

    #TODO: Replace python script with cmake script
    vcpkg_execute_required_process(
        COMMAND ${PYTHON3} ${CMAKE_CURRENT_LIST_DIR}/fixcmake.py
        WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/cmake
        LOGNAME fix-cmake
    )
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/qt5core)
    if(EXISTS ${CURRENT_PACKAGES_DIR}/tools/qt5/bin)
        file(COPY ${CURRENT_PACKAGES_DIR}/tools/qt5/bin DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
        vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin)
        vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/qt5/bin)
    endif()
    
    if(EXISTS ${CURRENT_PACKAGES_DIR}/tools/qt5/bin/qt.conf)
        file(REMOVE "${CURRENT_PACKAGES_DIR}/tools/qt5/bin/qt.conf")
    endif()

    qt_install_copyright(${SOURCE_PATH})
endif()
#install scripts for other qt ports
file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/fixcmake.py
    ${CMAKE_CURRENT_LIST_DIR}/cmake/qt_port_hashes.cmake
    ${CMAKE_CURRENT_LIST_DIR}/cmake/qt_port_functions.cmake
    ${CMAKE_CURRENT_LIST_DIR}/cmake/qt_fix_makefile_install.cmake
    ${CMAKE_CURRENT_LIST_DIR}/cmake/qt_fix_cmake.cmake
    ${CMAKE_CURRENT_LIST_DIR}/cmake/qt_fix_prl.cmake
    ${CMAKE_CURRENT_LIST_DIR}/cmake/qt_download_submodule.cmake
    ${CMAKE_CURRENT_LIST_DIR}/cmake/qt_build_submodule.cmake
    ${CMAKE_CURRENT_LIST_DIR}/cmake/qt_install_copyright.cmake
    ${CMAKE_CURRENT_LIST_DIR}/cmake/qt_submodule_installation.cmake
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/share/qt5
)

if(QT_BUILD_LATEST)
    file(COPY
        ${CMAKE_CURRENT_LIST_DIR}/cmake/qt_port_hashes_latest.cmake
        DESTINATION
            ${CURRENT_PACKAGES_DIR}/share/qt5
    )
endif()
