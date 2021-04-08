vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wxWidgets/wxWidgets
    REF v3.1.4
    SHA512 108e35220de10afbfc58762498ada9ece0b3166f56a6d11e11836d51bfbaed1de3033c32ed4109992da901fecddcf84ce8a1ba47303f728c159c638dac77d148
    HEAD_REF master
    PATCHES
        disable-platform-lib-dir.patch
        fix-stl-build-vs2019-16.6.patch
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

file(GLOB DLLS "${CURRENT_PACKAGES_DIR}/lib/*.dll")
if(DLLS)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    foreach(DLL ${DLLS})
        get_filename_component(N "${DLL}" NAME)
        file(RENAME ${DLL} ${CURRENT_PACKAGES_DIR}/bin/${N})
    endforeach()
endif()
file(GLOB DLLS "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
if(DLLS)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    foreach(DLL ${DLLS})
        get_filename_component(N "${DLL}" NAME)
        file(RENAME ${DLL} ${CURRENT_PACKAGES_DIR}/debug/bin/${N})
    endforeach()
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_copy_tools(TOOL_NAMES wxrc AUTO_CLEAN)
else()
    vcpkg_copy_tools(TOOL_NAMES wxrc wx-config wxrc-3.1 AUTO_CLEAN)
endif()

# do the copy pdbs now after the dlls got moved to the expected /bin folder above
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/msvc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(GLOB_RECURSE INCLUDES ${CURRENT_PACKAGES_DIR}/include/*.h)
if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/mswu/wx/setup.h)
    list(APPEND INCLUDES ${CURRENT_PACKAGES_DIR}/lib/mswu/wx/setup.h)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/mswud/wx/setup.h)
    list(APPEND INCLUDES ${CURRENT_PACKAGES_DIR}/debug/lib/mswud/wx/setup.h)
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

if(NOT EXISTS ${CURRENT_PACKAGES_DIR}/include/wx/setup.h)
    file(GLOB_RECURSE WX_SETUP_H_FILES_DBG ${CURRENT_PACKAGES_DIR}/debug/lib/*.h)
    file(GLOB_RECURSE WX_SETUP_H_FILES_REL ${CURRENT_PACKAGES_DIR}/lib/*.h)
    
    string(REPLACE "${CURRENT_PACKAGES_DIR}/debug/lib/" "" WX_SETUP_H_FILES_DBG "${WX_SETUP_H_FILES_DBG}")
    string(REPLACE "/setup.h" "" WX_SETUP_H_DBG_RELATIVE "${WX_SETUP_H_FILES_DBG}")
    
    string(REPLACE "${CURRENT_PACKAGES_DIR}/lib/" "" WX_SETUP_H_FILES_REL "${WX_SETUP_H_FILES_REL}")
    string(REPLACE "/setup.h" "" WX_SETUP_H_REL_RELATIVE "${WX_SETUP_H_FILES_REL}")
    
    configure_file(${CMAKE_CURRENT_LIST_DIR}/setup.h.in ${CURRENT_PACKAGES_DIR}/include/wx/setup.h @ONLY)
endif()
file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/wxwidgets)
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/wxwidgets/usage COPYONLY)
file(INSTALL ${SOURCE_PATH}/docs/licence.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
