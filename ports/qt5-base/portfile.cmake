vcpkg_buildpath_length_warning(37)

if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "qt5-base currently requires some packages from the system package manager. "
    "They can be installed on Ubuntu systems via "
    "sudo apt-get install '^libxcb.*-dev' libx11-xcb-dev libgl1-mesa-dev libxrender-dev "
    "libxi-dev libxkbcommon-dev libxkbcommon-x11-dev. For more information, see "
    "https://doc.qt.io/qt-5/linux.html and https://doc.qt.io/qt-5/linux-requirements.html"
    )
elseif(VCPKG_TARGET_IS_MINGW AND CMAKE_HOST_WIN32)
    find_program(MINGW32_MAKE mingw32-make PATHS ENV PATH NO_DEFAULT_PATH REQUIRED)
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

set(WITH_PGSQL_PLUGIN OFF)
if("postgresqlplugin" IN_LIST FEATURES)
    set(WITH_PGSQL_PLUGIN ON)
endif()

set(WITH_MYSQL_PLUGIN OFF)
if ("mysqlplugin" IN_LIST FEATURES)
    set(WITH_MYSQL_PLUGIN  ON)
endif()

set(WITH_OPENSSL OFF)
if ("openssl" IN_LIST FEATURES)
    set(WITH_OPENSSL ON)
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

set(PATCHES
    # CVE fixes from https://download.qt.io/archive/qt/5.15/
    patches/CVE-2025-4211-qtbase-5.15.diff
    patches/CVE-2025-5455-qtbase-5.15.patch
    patches/CVE-2025-30348-qtbase-5.15.diff

    patches/winmain_pro.patch          #Moves qtmain to manual-link
    patches/windows_prf.patch          #fixes the qtmain dependency due to the above move
    patches/qt_app.patch               #Moves the target location of qt5 host apps to always install into the host dir.
    patches/xlib.patch                 #Patches Xlib check to actually use Pkgconfig instead of makeSpec only
    patches/vulkan-windows.diff        #Forces QMake to use vulkan from vcpkg instead of VULKAN_SDK system variable
    patches/egl.patch                  #Fix egl detection logic.
    patches/qtbug_96392.patch          #Backport fix for QTBUG-96392
    patches/md4c.diff                  #Include vcpkg md4c.h
    patches/mysql_plugin_include.patch #Fix include path of mysql plugin
    patches/mysql-configure.patch      #Fix mysql project
    patches/patch-qtbase-memory_resource.diff # From https://bugreports.qt.io/browse/QTBUG-114316
    #patches/static_opengl.patch       #Use this patch if you really want to statically link angle on windows (e.g. using -opengl es2 and -static).
                                       #Be careful since it requires defining _GDI32_ for all dependent projects due to redefinition errors in the
                                       #the windows supplied gl.h header and the angle gl.h otherwise.

    # CMake fixes
    patches/Qt5BasicConfig.patch
    patches/Qt5PluginTarget.patch
    patches/create_cmake.patch
    patches/Qt5GuiConfigExtras.patch   # Patches the library search behavior for EGL since angle is not build with Qt
    patches/fix_angle.patch            # Failed to create OpenGL context for format QSurfaceFormat ...
    patches/mingw9.patch               # Fix compile with MinGW-W64 9.0.0: Redefinition of 'struct _FILE_ID_INFO'
    patches/qmake-arm64.patch          # Fix by Oliver Wolff to support ARM64 hosts on Windows
)
if(VCPKG_TARGET_IS_OSX)
    execute_process(COMMAND xcrun --sdk macosx --show-sdk-version
            OUTPUT_VARIABLE OSX_SDK_VERSION
            OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(${OSX_SDK_VERSION} VERSION_GREATER_EQUAL 26)
        # macOS 26 Tahoe has removed AGL APIs https://bugreports.qt.io/browse/QTBUG-137687
        list(APPEND PATCHES patches/macos26-opengl.patch)
    endif()
endif()

qt_download_submodule(OUT_SOURCE_PATH SOURCE_PATH PATCHES ${PATCHES})

# Remove vendored dependencies to ensure they are not picked up by the build
foreach(DEPENDENCY IN ITEMS double-conversion freetype harfbuzz-ng libjpeg libpng md4c pcre2 sqlite zlib)
    file(REMOVE_RECURSE "${SOURCE_PATH}/src/3rdparty/${DEPENDENCY}")
endforeach()

#########################
## Setup Configure options

set(CORE_OPTIONS
    -confirm-license
    -opensource
    #-simulator_and_device
    #-ltcg
    #-combined-angle-lib
    # ENV ANGLE_DIR to external angle source dir. (Will always be compiled with Qt)
    #-optimized-tools
    -force-debug-info
    -no-separate-debug-info
    -verbose
)

## 3rd Party Libs
list(APPEND CORE_OPTIONS
    -system-zlib
    -system-libjpeg
    -system-libmd4c
    -system-libpng
    -system-pcre
    -system-doubleconversion
    -no-angle # Qt does not need to build angle. VCPKG will build angle!
    -no-glib
    -no-feature-gssapi
    )

if(VCPKG_TARGET_IS_LINUX)
    # Accessibility uses at-spi2-core which links dbus,
    # so we link to ensure to use the same dbus library.
    list(APPEND CORE_OPTIONS -dbus-linked)
else()
    # Enable Qt DBus without linking to it.
    list(APPEND CORE_OPTIONS -dbus-runtime)
endif()

if(WITH_PGSQL_PLUGIN)
    list(APPEND CORE_OPTIONS -sql-psql)
else()
    list(APPEND CORE_OPTIONS -no-sql-psql)
endif()
if(WITH_MYSQL_PLUGIN)
    list(APPEND CORE_OPTIONS -sql-mysql)
else()
    list(APPEND CORE_OPTIONS -no-sql-mysql)
endif()

if(WITH_OPENSSL)
    list(APPEND CORE_OPTIONS -openssl-linked)
else()
    list(APPEND CORE_OPTIONS -no-openssl)
endif()

if("cups" IN_LIST FEATURES)
    message(WARNING "${PORT} feature 'cups' requires libcups2-dev from system package manger.")
    list(APPEND CORE_OPTIONS -cups)
else()
    list(APPEND CORE_OPTIONS -no-cups)
endif()

if ("vulkan" IN_LIST FEATURES)
    list(APPEND CORE_OPTIONS --vulkan=yes)
else()
    list(APPEND CORE_OPTIONS --vulkan=no)
endif()

find_library(ZLIB_RELEASE NAMES z zlib PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(ZLIB_DEBUG NAMES z zlib zd zlibd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(JPEG_RELEASE NAMES jpeg jpeg-static PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(JPEG_DEBUG NAMES jpeg jpeg-static jpegd jpeg-staticd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(LIBPNG_RELEASE NAMES png16 libpng16 PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH) #Depends on zlib
find_library(LIBPNG_DEBUG NAMES png16 png16d libpng16 libpng16d PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(PSQL_RELEASE NAMES pq libpq PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH) # Depends on openssl and zlib(linux)
find_library(PSQL_DEBUG NAMES pq libpq pqd libpqd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)

if(NOT (PSQL_RELEASE MATCHES ".*\.so") AND NOT (PSQL_DEBUG MATCHES ".*\.so"))
    find_library(PSQL_COMMON_RELEASE NAMES pgcommon libpgcommon PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH) # Depends on openssl and zlib(linux)
    find_library(PSQL_COMMON_DEBUG NAMES pgcommon libpgcommon pgcommond libpgcommond PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
    find_library(PSQL_PORT_RELEASE NAMES pgport libpgport PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH) # Depends on openssl and zlib(linux)
    find_library(PSQL_PORT_DEBUG NAMES pgport libpgport pgportd libpgportd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
endif()
find_library(MYSQL_RELEASE NAMES libmysql mysqlclient PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH) # Depends on openssl and zlib(linux)
find_library(MYSQL_DEBUG NAMES libmysql libmysqld mysqlclient mysqlclientd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)

find_library(PCRE2_RELEASE NAMES pcre2-16 pcre2-16-static PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(PCRE2_DEBUG NAMES pcre2-16 pcre2-16-static pcre2-16d pcre2-16-staticd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)

find_library(ICUUC_RELEASE NAMES icuuc libicuuc PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(ICUUC_DEBUG NAMES icuucd libicuucd icuuc libicuuc PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(ICUIO_RELEASE NAMES icuio libicuio PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(ICUIO_DEBUG NAMES icuiod libicuiod icuio libicuio PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(ICUIN_RELEASE NAMES icui18n libicui18n icuin PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(ICUIN_DEBUG NAMES icui18nd libicui18nd icui18n libicui18n icuin icuind PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(ICUDATA_RELEASE NAMES icudata libicudata icudt PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(ICUDATA_DEBUG NAMES icudatad libicudatad icudata libicudata icudtd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
set(ICU_RELEASE "${ICUIN_RELEASE} ${ICULX_RELEASE} ${ICUUC_RELEASE} ${ICUIO_RELEASE} ${ICUDATA_RELEASE}")
set(ICU_DEBUG "${ICUIN_DEBUG} ${ICULX_DEBUG} ${ICUUC_DEBUG} ${ICUIO_DEBUG} ${ICUDATA_DEBUG}")
if(VCPKG_TARGET_IS_WINDOWS)
    set(ICU_RELEASE "${ICU_RELEASE} -ladvapi32")
    set(ICU_DEBUG "${ICU_DEBUG} -ladvapi32" )
endif()

#Dependent libraries
find_library(SSL_RELEASE ssl ssleay32 PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(SSL_DEBUG ssl ssleay32 ssld ssleay32d PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(EAY_RELEASE libeay32 crypto libcrypto PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(EAY_DEBUG libeay32 crypto libcrypto libeay32d cryptod libcryptod PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)

set(RELEASE_OPTIONS
            "LIBJPEG_LIBS=${JPEG_RELEASE}"
            "ZLIB_LIBS=${ZLIB_RELEASE}"
            "LIBPNG_LIBS=${LIBPNG_RELEASE} ${ZLIB_RELEASE}"
            "PCRE2_LIBS=${PCRE2_RELEASE}"
            "QMAKE_LIBS_PRIVATE+=${LIBPNG_RELEASE} ${ZLIB_RELEASE}"
            )
set(DEBUG_OPTIONS
            "LIBJPEG_LIBS=${JPEG_DEBUG}"
            "ZLIB_LIBS=${ZLIB_DEBUG}"
            "LIBPNG_LIBS=${LIBPNG_DEBUG} ${ZLIB_DEBUG}"
            "PCRE2_LIBS=${PCRE2_DEBUG}"
            "QMAKE_LIBS_PRIVATE+=${LIBPNG_DEBUG} ${ZLIB_DEBUG}"
            )

x_vcpkg_pkgconfig_get_modules(PREFIX freetype MODULES freetype2 LIBS)
list(APPEND CORE_OPTIONS -system-freetype)
list(APPEND RELEASE_OPTIONS "FREETYPE_LIBS=${freetype_LIBS_RELEASE}")
list(APPEND DEBUG_OPTIONS "FREETYPE_LIBS=${freetype_LIBS_DEBUG}")

x_vcpkg_pkgconfig_get_modules(PREFIX harfbuzz MODULES harfbuzz LIBS)
if(VCPKG_TARGET_IS_OSX)
    string(APPEND harfbuzz_LIBRARIES_RELEASE " -framework ApplicationServices")
    string(APPEND harfbuzz_LIBRARIES_DEBUG " -framework ApplicationServices")
endif()
list(APPEND CORE_OPTIONS -system-harfbuzz)
list(APPEND RELEASE_OPTIONS "HARFBUZZ_LIBS=${harfbuzz_LIBS_RELEASE}")
list(APPEND DEBUG_OPTIONS "HARFBUZZ_LIBS=${harfbuzz_LIBS_DEBUG}")

if(NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND CORE_OPTIONS -fontconfig)
    x_vcpkg_pkgconfig_get_modules(PREFIX fontconfig MODULES fontconfig LIBS)
    list(APPEND RELEASE_OPTIONS "FONTCONFIG_LIBS=${fontconfig_LIBS_RELEASE}")
    list(APPEND DEBUG_OPTIONS "FONTCONFIG_LIBS=${fontconfig_LIBS_DEBUG}")
endif()

if("sqlite3plugin" IN_LIST FEATURES)
    list(APPEND CORE_OPTIONS -system-sqlite)
    x_vcpkg_pkgconfig_get_modules(PREFIX sqlite3 MODULES sqlite3 LIBS)
    list(APPEND RELEASE_OPTIONS "SQLITE_LIBS=${sqlite3_LIBS_RELEASE}")
    list(APPEND DEBUG_OPTIONS "SQLITE_LIBS=${sqlite3_LIBS_DEBUG}")
else()
    list(APPEND CORE_OPTIONS -no-sql-sqlite)
endif()

if("zstd" IN_LIST FEATURES)
    list(APPEND CORE_OPTIONS -zstd)
    x_vcpkg_pkgconfig_get_modules(PREFIX libzstd MODULES libzstd LIBS)
    list(APPEND RELEASE_OPTIONS "QMAKE_LIBS_PRIVATE+=${libzstd_LIBS_RELEASE}")
    list(APPEND DEBUG_OPTIONS "QMAKE_LIBS_PRIVATE+=${libzstd_LIBS_DEBUG}")
else()
    list(APPEND CORE_OPTIONS -no-zstd)
endif()

if("icu" IN_LIST FEATURES)
    list(APPEND CORE_OPTIONS -icu)

    # This if/else corresponds to icu setup in src/corelib/configure.json.
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        list(APPEND CORE_OPTIONS
            "ICU_LIBS_RELEASE=${ICU_RELEASE}"
            "ICU_LIBS_DEBUG=${ICU_DEBUG}"
        )
    else()
        list(APPEND RELEASE_OPTIONS "ICU_LIBS=${ICU_RELEASE}")
        list(APPEND DEBUG_OPTIONS "ICU_LIBS=${ICU_DEBUG}")
    endif()

    list(APPEND RELEASE_OPTIONS "QMAKE_LIBS_PRIVATE+=${ICU_RELEASE}")
    list(APPEND DEBUG_OPTIONS "QMAKE_LIBS_PRIVATE+=${ICU_DEBUG}")
else()
    list(APPEND CORE_OPTIONS -no-icu)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_IS_UWP)
        list(APPEND CORE_OPTIONS -appstore-compliant)
    endif()
    if(NOT ${VCPKG_LIBRARY_LINKAGE} STREQUAL "static")
        list(APPEND CORE_OPTIONS -opengl dynamic) # other options are "-no-opengl", "-opengl angle", and "-opengl desktop" and "-opengel es2"
    else()
        list(APPEND CORE_OPTIONS -opengl dynamic) # other possible option without moving angle dlls: "-opengl desktop". "-opengel es2" only works with commented patch
    endif()
    set(ADDITIONAL_WINDOWS_LIBS "-lws2_32 -lsecur32 -ladvapi32 -lshell32 -lcrypt32 -luser32 -lgdi32")

    if(WITH_OPENSSL)
        list(APPEND RELEASE_OPTIONS "OPENSSL_LIBS=${SSL_RELEASE} ${EAY_RELEASE} ${ADDITIONAL_WINDOWS_LIBS}")
        list(APPEND DEBUG_OPTIONS "OPENSSL_LIBS=${SSL_DEBUG} ${EAY_DEBUG} ${ADDITIONAL_WINDOWS_LIBS}")
    else()
        list(APPEND CORE_OPTIONS -schannel)
    endif()

    if(WITH_PGSQL_PLUGIN)
        list(APPEND RELEASE_OPTIONS "PSQL_LIBS=${PSQL_RELEASE} ${PSQL_PORT_RELEASE} ${PSQL_COMMON_RELEASE} ${SSL_RELEASE} ${EAY_RELEASE} ${ADDITIONAL_WINDOWS_LIBS} -lwldap32")
        list(APPEND DEBUG_OPTIONS "PSQL_LIBS=${PSQL_DEBUG} ${PSQL_PORT_DEBUG} ${PSQL_COMMON_DEBUG} ${SSL_DEBUG} ${EAY_DEBUG} ${ADDITIONAL_WINDOWS_LIBS} -lwldap32")
    endif()
elseif(VCPKG_TARGET_IS_LINUX)
    list(APPEND CORE_OPTIONS -xcb-xlib -xcb -linuxfb)

    if(WITH_OPENSSL)
        list(APPEND RELEASE_OPTIONS "OPENSSL_LIBS=${SSL_RELEASE} ${EAY_RELEASE} -ldl -lpthread")
        list(APPEND DEBUG_OPTIONS "OPENSSL_LIBS=${SSL_DEBUG} ${EAY_DEBUG} -ldl -lpthread")
    endif()

    if(WITH_PGSQL_PLUGIN)
        list(APPEND RELEASE_OPTIONS "PSQL_LIBS=${PSQL_RELEASE} ${PSQL_PORT_RELEASE} ${PSQL_TYPES_RELEASE} ${PSQL_COMMON_RELEASE} ${SSL_RELEASE} ${EAY_RELEASE} -ldl -lpthread")
        list(APPEND DEBUG_OPTIONS "PSQL_LIBS=${PSQL_DEBUG} ${PSQL_PORT_DEBUG} ${PSQL_TYPES_DEBUG} ${PSQL_COMMON_DEBUG} ${SSL_DEBUG} ${EAY_DEBUG} -ldl -lpthread")
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        # Avoid frameworks for vcpkg
        list(APPEND CORE_OPTIONS -no-framework)
        # Such that Qt executables like moc find their libs. The default path is ../Frameworks
        list(APPEND DEBUG_OPTIONS -R ${CURRENT_INSTALLED_DIR}/debug/lib)
        list(APPEND RELEASE_OPTIONS -R ${CURRENT_INSTALLED_DIR}/lib)
    endif()

    if("${VCPKG_TARGET_ARCHITECTURE}" MATCHES "arm64")
        FILE(READ "${SOURCE_PATH}/mkspecs/common/macx.conf" _tmp_contents)
        string(REPLACE "QMAKE_APPLE_DEVICE_ARCHS = x86_64" "QMAKE_APPLE_DEVICE_ARCHS = arm64" _tmp_contents ${_tmp_contents})
        FILE(WRITE "${SOURCE_PATH}/mkspecs/common/macx.conf" ${_tmp_contents})
    endif()
    if(DEFINED VCPKG_OSX_DEPLOYMENT_TARGET)
        set(ENV{QMAKE_MACOSX_DEPLOYMENT_TARGET} ${VCPKG_OSX_DEPLOYMENT_TARGET})
    else()
        message(STATUS "Detected OSX SDK Version: ${OSX_SDK_VERSION}")
        string(REGEX MATCH "^([0-9]+)\\.([0-9]+)" OSX_SDK_VERSION "${OSX_SDK_VERSION}")
        message(STATUS "Major.Minor OSX SDK Version: ${OSX_SDK_VERSION}")

        execute_process(COMMAND sw_vers -productVersion
                OUTPUT_VARIABLE VCPKG_OSX_DEPLOYMENT_TARGET
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        message(STATUS "Detected OSX system Version: ${VCPKG_OSX_DEPLOYMENT_TARGET}")
        string(REGEX MATCH "^([0-9]+)\\.([0-9]+)" VCPKG_OSX_DEPLOYMENT_TARGET "${VCPKG_OSX_DEPLOYMENT_TARGET}")
        message(STATUS "Major.Minor OSX system Version: ${VCPKG_OSX_DEPLOYMENT_TARGET}")

        # Parse mkspecs/common/macx.conf
        file(READ "${SOURCE_PATH}/mkspecs/common/macx.conf" QT_MK_MAC_CONTENT)
        string(REGEX MATCHALL "QT_MAC_SDK_VERSION_MIN[ \t]*=[ \t]*(([0-9]+)(\\.([0-9]+))*)" KEY_VALUE "${QT_MK_MAC_CONTENT}")
        if(${CMAKE_MATCH_COUNT} LESS 2)
            message(FATAL_ERROR "Error parse QT_MAC_SDK_VERSION_MIN")
        endif()
        set(QT_MAC_SDK_VERSION_MIN "${CMAKE_MATCH_1}")
        string(REGEX MATCHALL "QT_MAC_SDK_VERSION_MAX[ \t]*=[ \t]*(([0-9]+)(\\.([0-9]+))*)" KEY_VALUE "${QT_MK_MAC_CONTENT}")
        if(${CMAKE_MATCH_COUNT} LESS 2)
            message(FATAL_ERROR "Error parse QT_MAC_SDK_VERSION_MAX")
        endif()
        set(QT_MAC_SDK_VERSION_MAX "${CMAKE_MATCH_1}")

        message(STATUS "QT_MAC_SDK_VERSION_MIN: ${QT_MAC_SDK_VERSION_MIN}")
        message(STATUS "QT_MAC_SDK_VERSION_MAX: ${QT_MAC_SDK_VERSION_MAX}")

        # clamp(VCPKG_OSX_DEPLOYMENT_TARGET, QT_MAC_SDK_VERSION_MIN, QT_MAC_SDK_VERSION_MAX)
        if("${VCPKG_OSX_DEPLOYMENT_TARGET}" VERSION_GREATER "${QT_MAC_SDK_VERSION_MAX}")
            set(VCPKG_OSX_DEPLOYMENT_TARGET "${QT_MAC_SDK_VERSION_MAX}")
        endif()
        if("${VCPKG_OSX_DEPLOYMENT_TARGET}" VERSION_LESS "${QT_MAC_SDK_VERSION_MIN}")
            set(VCPKG_OSX_DEPLOYMENT_TARGET "${QT_MAC_SDK_VERSION_MIN}")
        endif()

        set(ENV{QMAKE_MACOSX_DEPLOYMENT_TARGET} ${VCPKG_OSX_DEPLOYMENT_TARGET})
    endif()
    message(STATUS "Enviromnent OSX SDK Version: $ENV{QMAKE_MACOSX_DEPLOYMENT_TARGET}")
    file(READ "${SOURCE_PATH}/mkspecs/common/macx.conf" _tmp_contents)
    string(REPLACE "QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.13" "QMAKE_MACOSX_DEPLOYMENT_TARGET = ${VCPKG_OSX_DEPLOYMENT_TARGET}" _tmp_contents ${_tmp_contents})
    file(WRITE "${SOURCE_PATH}/mkspecs/common/macx.conf" ${_tmp_contents})
    #list(APPEND QT_PLATFORM_CONFIGURE_OPTIONS HOST_PLATFORM ${TARGET_MKSPEC})

    if(WITH_OPENSSL)
        list(APPEND RELEASE_OPTIONS "OPENSSL_LIBS=${SSL_RELEASE} ${EAY_RELEASE} -ldl -lpthread")
        list(APPEND DEBUG_OPTIONS "OPENSSL_LIBS=${SSL_DEBUG} ${EAY_DEBUG} -ldl -lpthread")
    endif()

    if(WITH_PGSQL_PLUGIN)
        list(APPEND RELEASE_OPTIONS "PSQL_LIBS=${PSQL_RELEASE} ${PSQL_PORT_RELEASE} ${PSQL_TYPES_RELEASE} ${PSQL_COMMON_RELEASE} ${SSL_RELEASE} ${EAY_RELEASE} -ldl -lpthread")
        list(APPEND DEBUG_OPTIONS "PSQL_LIBS=${PSQL_DEBUG} ${PSQL_PORT_DEBUG} ${PSQL_TYPES_DEBUG} ${PSQL_COMMON_DEBUG} ${SSL_DEBUG} ${EAY_DEBUG} -ldl -lpthread")
    endif()
endif()

if (WITH_MYSQL_PLUGIN)
    list(APPEND RELEASE_OPTIONS "MYSQL_LIBS=${MYSQL_RELEASE} ${SSL_RELEASE} ${EAY_RELEASE} ${ZLIB_RELEASE} ${ADDITIONAL_WINDOWS_LIBS}")
    list(APPEND DEBUG_OPTIONS "MYSQL_LIBS=${MYSQL_DEBUG} ${SSL_DEBUG} ${EAY_DEBUG} ${ZLIB_DEBUG} ${ADDITIONAL_WINDOWS_LIBS}")
endif(WITH_MYSQL_PLUGIN)

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

    #This needs a new VCPKG policy or a static angle build (ANGLE needs to be fixed in VCPKG!)
    if(VCPKG_TARGET_IS_WINDOWS AND ${VCPKG_LIBRARY_LINKAGE} MATCHES "static") # Move angle dll libraries
        if(EXISTS "${CURRENT_PACKAGES_DIR}/bin")
            message(STATUS "Moving ANGLE dlls from /bin to /tools/qt5-angle/bin. In static builds dlls are not allowed in /bin")
            file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/qt5-angle)
            file(RENAME ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/tools/qt5-angle/bin)
            if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/bin)
                file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/qt5-angle/debug)
                file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/tools/qt5-angle/debug/bin)
            endif()
        endif()
    endif()

    ## Fix location of qtmain(d).lib. Has been moved into manual-link. Add debug version
    set(cmakefile "${CURRENT_PACKAGES_DIR}/share/cmake/Qt5Core/Qt5CoreConfigExtras.cmake")
    file(READ "${cmakefile}" _contents)
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_BUILD_TYPE)
        string(REPLACE "set_property(TARGET Qt5::WinMain APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)" "set_property(TARGET Qt5::WinMain APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE DEBUG)" _contents "${_contents}")
        string(REPLACE
        [[set(imported_location "${_qt5Core_install_prefix}/lib/qtmain.lib")]]
        [[set(imported_location_release "${_qt5Core_install_prefix}/lib/manual-link/qtmain.lib")
          set(imported_location_debug "${_qt5Core_install_prefix}/debug/lib/manual-link/qtmaind.lib")]]
          _contents "${_contents}")
        string(REPLACE
[[    set_target_properties(Qt5::WinMain PROPERTIES
        IMPORTED_LOCATION_RELEASE ${imported_location}
    )]]
[[    set_target_properties(Qt5::WinMain PROPERTIES
        IMPORTED_LOCATION_RELEASE ${imported_location_release}
        IMPORTED_LOCATION_DEBUG ${imported_location_debug}
    )]]
    _contents "${_contents}")
    else() # Single configuration build (either debug or release)
        # Release case
        string(REPLACE
            [[set(imported_location "${_qt5Core_install_prefix}/lib/qtmain.lib")]]
            [[set(imported_location "${_qt5Core_install_prefix}/lib/manual-link/qtmain.lib")]]
            _contents "${_contents}")
        # Debug case (whichever will match)
        string(REPLACE
            [[set(imported_location "${_qt5Core_install_prefix}/lib/qtmaind.lib")]]
            [[set(imported_location "${_qt5Core_install_prefix}/debug/lib/manual-link/qtmaind.lib")]]
            _contents "${_contents}")
        string(REPLACE
            [[set(imported_location "${_qt5Core_install_prefix}/debug/lib/qtmaind.lib")]]
            [[set(imported_location "${_qt5Core_install_prefix}/debug/lib/manual-link/qtmaind.lib")]]
            _contents "${_contents}")
    endif()
    file(WRITE "${cmakefile}" "${_contents}")

    if(EXISTS ${CURRENT_PACKAGES_DIR}/tools/qt5/bin)
        file(COPY ${CURRENT_PACKAGES_DIR}/tools/qt5/bin DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
        vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin)
        vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/qt5/bin)
    endif()
    # This should be removed if possible! (Currently debug build of qt5-translations requires it.)
    if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/tools/qt5/bin)
        file(COPY ${CURRENT_PACKAGES_DIR}/tools/qt5/bin DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qt5/debug)
        vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/qt5/debug/bin)
    endif()

    if(EXISTS ${CURRENT_PACKAGES_DIR}/tools/qt5/bin/qt.conf)
        file(REMOVE "${CURRENT_PACKAGES_DIR}/tools/qt5/bin/qt.conf")
    endif()
    set(CURRENT_INSTALLED_DIR_BACKUP "${CURRENT_INSTALLED_DIR}")
    set(CURRENT_INSTALLED_DIR "./../../.." ) # Making the qt.conf relative and not absolute
    configure_file(${CURRENT_PACKAGES_DIR}/tools/qt5/qt_release.conf ${CURRENT_PACKAGES_DIR}/tools/qt5/bin/qt.conf) # This makes the tools at least useable for release
    set(CURRENT_INSTALLED_DIR "${CURRENT_INSTALLED_DIR_BACKUP}")

    qt_install_copyright(${SOURCE_PATH})
endif()
#install scripts for other qt ports
file(COPY
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

# Fix Qt5GuiConfigExtras EGL path
if(VCPKG_TARGET_IS_LINUX)
    set(_file "${CURRENT_PACKAGES_DIR}/share/cmake/Qt5Gui/Qt5GuiConfigExtras.cmake")
    file(READ "${_file}" _contents)
    string(REGEX REPLACE "_qt5gui_find_extra_libs\\\(EGL[^\\\n]+" "_qt5gui_find_extra_libs(EGL \"EGL\" \"\" \"\${_qt5Gui_install_prefix}/include\")\n" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()

vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_OSX)
    file(GLOB _debug_files "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/*_debug.pc")
    foreach(_file ${_debug_files})
        string(REGEX REPLACE "_debug\\.pc$" ".pc" _new_filename "${_file}")
        string(REGEX MATCH "(Qt5[a-zA-Z]+)_debug\\.pc$" _not_used "${_file}")
        set(_name ${CMAKE_MATCH_1})
        file(STRINGS "${_file}" _version REGEX "^(Version):.+$")
        file(WRITE "${_new_filename}" "Name: ${_name}\nDescription: Forwarding to the _debug version by vcpkg\n${_version}\nRequires: ${_name}_debug\n")
    endforeach()
endif()
# #Code to get generated CMake files from CI
# file(RENAME "${CURRENT_PACKAGES_DIR}/share/cmake/Qt5Core/Qt5CoreConfig.cmake" "${CURRENT_BUILDTREES_DIR}/Qt5CoreConfig.cmake.log")
# file(GLOB_RECURSE CMAKE_GUI_FILES "${CURRENT_PACKAGES_DIR}/share/cmake/Qt5Gui/*.cmake" )
# foreach(cmake_file ${CMAKE_GUI_FILES})
    # get_filename_component(cmake_filename "${cmake_file}" NAME)
    # file(COPY "${cmake_file}" DESTINATION "${CURRENT_BUILDTREES_DIR}")
    # file(RENAME "${CURRENT_BUILDTREES_DIR}/${cmake_filename}" "${CURRENT_BUILDTREES_DIR}/${cmake_filename}.log")
# endforeach()
# #Copy config.log from buildtree/triplet to buildtree to get the log in CI in case of failure
# if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/config.log")
    # file(RENAME "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/config.log" "${CURRENT_BUILDTREES_DIR}/config-rel.log")
# endif()
# if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/config.log")
    # file(RENAME "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/config.log" "${CURRENT_BUILDTREES_DIR}/config-dbg.log")
# endif()
# message(FATAL_ERROR "Need Info from CI!")
