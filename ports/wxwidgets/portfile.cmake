vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wxWidgets/wxWidgets
    REF 9c0a8be1dc32063d91ed1901fd5fcd54f4f955a1 #v3.1.5
    SHA512 33817f766b36d24e5e6f4eb7666f2e4c1ec305063cb26190001e0fc82ce73decc18697e8005da990a1c99dc1ccdac9b45bb2bbe5ba73e6e2aa860c768583314c
    HEAD_REF master
    PATCHES
        disable-platform-lib-dir.patch
        fix-build.patch
        fix-wx-config-path.patch
        fix-install-path.patch
        export-targets.patch
        fix-wxconfig-libs-output.patch # Remove this patch in the next update
        fix-file-generate.patch # https://github.com/wxWidgets/wxWidgets/pull/2404
)

set(OPTIONS)
if(VCPKG_TARGET_IS_OSX)
    set(OPTIONS -DCOTIRE_MINIMUM_NUMBER_OF_TARGET_SOURCES=9999)
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64 OR VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
    set(OPTIONS
        -DwxUSE_OPENGL=OFF
        -DwxUSE_STACKWALKER=OFF
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DwxUSE_REGEX=builtin
        -DwxUSE_ZLIB=sys
        -DwxUSE_EXPAT=sys
        -DwxUSE_LIBJPEG=sys
        -DwxUSE_LIBPNG=sys
        -DwxUSE_LIBTIFF=sys
        -DwxUSE_STL=ON
        -DwxBUILD_DISABLE_PLATFORM_LIB_DIR=ON
        ${OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-wxwidgets TARGET_PATH share/unofficial-wxwidgets)

set(tools wxrc)
if(NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND tools wx-config wxrc-3.1)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    # Copy debug tools
    vcpkg_copy_tools(
        TOOL_NAMES ${tools}
        SEARCH_DIR "${CURRENT_PACKAGES_DIR}/debug/bin"
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug"
    )
endif()
vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)

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
    
    string(REPLACE "${CURRENT_PACKAGES_DIR}/debug/lib/" "" WX_SETUP_H_FILES_DBG "${WX_SETUP_H_FILES_DBG}")
    string(REPLACE "/setup.h" "" WX_SETUP_H_DBG_RELATIVE "${WX_SETUP_H_FILES_DBG}")
    
    string(REPLACE "${CURRENT_PACKAGES_DIR}/lib/" "" WX_SETUP_H_FILES_REL "${WX_SETUP_H_FILES_REL}")
    string(REPLACE "/setup.h" "" WX_SETUP_H_REL_RELATIVE "${WX_SETUP_H_FILES_REL}")
    
    configure_file("${CMAKE_CURRENT_LIST_DIR}/setup.h.in" "${CURRENT_PACKAGES_DIR}/include/wx/setup.h" @ONLY)
endif()

# Fix the abs path in wx-config
if (NOT VCPKG_TARGET_IS_WINDOWS)
    file(READ "${CURRENT_PACKAGES_DIR}/tools/wxwidgets/wx-config" _contents)
    string(REGEX REPLACE "${CURRENT_PACKAGES_DIR}" "\${prefix}" _contents "${_contents}")
    string(REGEX REPLACE "${CURRENT_INSTALLED_DIR}" "\${prefix}" _contents "${_contents}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/tools/wxwidgets/wx-config" "${_contents}")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in"
   "${CURRENT_PACKAGES_DIR}/share/wxwidgets/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${SOURCE_PATH}/docs/licence.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
