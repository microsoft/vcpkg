vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wxWidgets/wxWidgets
    REF 35a6d7b15fedfdb5198bb6c28b31cda33b2c2a76 #v3.1.6-final
    SHA512 f42b97a695e037130da9935e3abf117c0720325f194fcdabace95fa16a5ca06d49e35db9616bb0ef16600044397739459551a6276f3c239bd4fc160ecb6cdc16
    HEAD_REF master
    PATCHES
        install-layout.patch
        relocatable-wx-config.patch
        nanosvg-ext-depend.patch
        fix-libs-export.patch
        fix-pcre2.patch
)

if(VCPKG_TARGET_IS_LINUX)
    message(WARNING [[
Port wxwidgets currently requires the following packages from the system package manager:
    pkg-config
    GTK 3
    libsecret
    libgcrypt
    libsystemd
These development packages can be installed on Ubuntu systems via
    sudo apt-get install pkg-config libgtk-3-dev libsecret-1-dev libgcrypt20-dev libsystemd-dev
]])
    foreach(conflicting_port IN ITEMS freetype glib)
        if(EXISTS "${CURRENT_INSTALLED_DIR}/share/${conflicting_port}/copyright")
            message(FATAL_ERROR "Port ${conflicting_port} must not be installed when building ${PORT}:${TARGET_TRIPLET}.")
        endif()
    endforeach()
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sound   wxUSE_SOUND
)

vcpkg_find_acquire_program(PKGCONFIG)

set(OPTIONS "")
if(VCPKG_TARGET_IS_OSX)
    list(APPEND OPTIONS -DCOTIRE_MINIMUM_NUMBER_OF_TARGET_SOURCES=9999)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm"))
    list(APPEND OPTIONS
        -DwxUSE_OPENGL=OFF
        -DwxUSE_STACKWALKER=OFF
    )
endif()

if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_OSX)
    list(APPEND OPTIONS -DwxUSE_WEBREQUEST_CURL=OFF)
else()
    list(APPEND OPTIONS -DwxUSE_WEBREQUEST_CURL=ON)
endif()

# wxWidgets on Linux currently needs to find the system's `gtk+-3.0.pc`.
# vcpkg's port pkgconf would prevent this lookup.
if(VCPKG_TARGET_IS_LINUX AND NOT VCPKG_CROSSCOMPILING AND NOT DEFINED ENV{PKG_CONFIG})
    find_program(system_pkg_config NAMES pkg-config)
    if(system_pkg_config)
        set(ENV{PKG_CONFIG} "${system_pkg_config}")
    endif()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        list(APPEND OPTIONS -DPKG_CONFIG_ARGN=--static)
    endif()
endif()

# This may be set to ON by users in a custom triplet.
# The use of 'wxUSE_STL' and 'WXWIDGETS_USE_STD_CONTAINERS' (ON or OFF) are not API compatible
# which is why they must be set in a custom triplet rather than a port feature.
if(NOT DEFINED WXWIDGETS_USE_STL)
    set(WXWIDGETS_USE_STL OFF)
endif()

if(NOT DEFINED WXWIDGETS_USE_STD_CONTAINERS)
    set(WXWIDGETS_USE_STD_CONTAINERS OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DwxUSE_REGEX=sys
        -DwxUSE_ZLIB=sys
        -DwxUSE_EXPAT=sys
        -DwxUSE_LIBJPEG=sys
        -DwxUSE_LIBPNG=sys
        -DwxUSE_LIBTIFF=sys
        -DwxUSE_SECRETSTORE=FALSE
        -DwxBUILD_DISABLE_PLATFORM_LIB_DIR=ON
        -DwxUSE_STL=${WXWIDGETS_USE_STL}
        -DwxUSE_STD_CONTAINERS=${WXWIDGETS_USE_STD_CONTAINERS}
        ${OPTIONS}
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        # The minimum cmake version requirement for Cotire is 2.8.12.
        # however, we need to declare that the minimum cmake version requirement is at least 3.1 to use CMAKE_PREFIX_PATH as the path to find .pc.
        -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=ON
)

vcpkg_cmake_install()

set(tools wxrc)
if(VCPKG_TARGET_IS_MINGW OR NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND tools wxrc-3.1)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/wx-config" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/wx-config")
    if(NOT VCPKG_BUILD_TYPE)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/wx-config" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/wx-config")
    endif()
endif()
vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)

# do the copy pdbs now after the dlls got moved to the expected /bin folder above
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/msvc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(GLOB_RECURSE INCLUDES "${CURRENT_PACKAGES_DIR}/include/*.h")
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/mswu/wx/setup.h")
    list(APPEND INCLUDES "${CURRENT_PACKAGES_DIR}/lib/mswu/wx/setup.h")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/mswud/wx/setup.h")
    list(APPEND INCLUDES "${CURRENT_PACKAGES_DIR}/debug/lib/mswud/wx/setup.h")
endif()
foreach(INC IN LISTS INCLUDES)
    file(READ "${INC}" _contents)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        string(REPLACE "defined(WXUSINGDLL)" "0" _contents "${_contents}")
    else()
        string(REPLACE "defined(WXUSINGDLL)" "1" _contents "${_contents}")
    endif()
    # Remove install prefix from setup.h to ensure package is relocatable
    string(REGEX REPLACE "\n#define wxINSTALL_PREFIX [^\n]*" "\n#define wxINSTALL_PREFIX \"\"" _contents "${_contents}")
    file(WRITE "${INC}" "${_contents}")
endforeach()

if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/include/wx/setup.h")
    file(GLOB_RECURSE WX_SETUP_H_FILES_DBG "${CURRENT_PACKAGES_DIR}/debug/lib/*.h")
    file(GLOB_RECURSE WX_SETUP_H_FILES_REL "${CURRENT_PACKAGES_DIR}/lib/*.h")

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        vcpkg_replace_string("${WX_SETUP_H_FILES_REL}" "${CURRENT_PACKAGES_DIR}" "")

        string(REPLACE "${CURRENT_PACKAGES_DIR}/lib/" "" WX_SETUP_H_FILES_REL "${WX_SETUP_H_FILES_REL}")
        string(REPLACE "/setup.h" "" WX_SETUP_H_REL_RELATIVE "${WX_SETUP_H_FILES_REL}")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        vcpkg_replace_string("${WX_SETUP_H_FILES_DBG}" "${CURRENT_PACKAGES_DIR}" "")

        string(REPLACE "${CURRENT_PACKAGES_DIR}/debug/lib/" "" WX_SETUP_H_FILES_DBG "${WX_SETUP_H_FILES_DBG}")
        string(REPLACE "/setup.h" "" WX_SETUP_H_DBG_RELATIVE "${WX_SETUP_H_FILES_DBG}")
    endif()

    configure_file("${CMAKE_CURRENT_LIST_DIR}/setup.h.in" "${CURRENT_PACKAGES_DIR}/include/wx/setup.h" @ONLY)
endif()

file(GLOB configs LIST_DIRECTORIES false "${CURRENT_PACKAGES_DIR}/lib/wx/config/*" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/wx-config")
foreach(config IN LISTS configs)
    vcpkg_replace_string("${config}" "${CURRENT_INSTALLED_DIR}" [[${prefix}]])
endforeach()
file(GLOB configs LIST_DIRECTORIES false "${CURRENT_PACKAGES_DIR}/debug/lib/wx/config/*" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/wx-config")
foreach(config IN LISTS configs)
    vcpkg_replace_string("${config}" "${CURRENT_INSTALLED_DIR}/debug" [[${prefix}]])
endforeach()

# For CMake multi-config in connection with wrapper
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/mswud/wx/setup.h")
    file(INSTALL "${CURRENT_PACKAGES_DIR}/debug/lib/mswud/wx/setup.h"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib/mswud/wx"
    )
endif()

if("example" IN_LIST FEATURES)
    file(INSTALL
        "${CMAKE_CURRENT_LIST_DIR}/example/CMakeLists.txt"
        "${SOURCE_PATH}/samples/popup/popup.cpp"
        "${SOURCE_PATH}/samples/sample.xpm"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/example"
    )
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/example/popup.cpp" "../sample.xpm" "sample.xpm")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/docs/licence.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
