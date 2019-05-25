include(vcpkg_common_functions)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO 01org/tbb
    REF 4233fef583b4f8cbf9f781311717600feaaa0694
    SHA512 d1dd29d6b0276deb71e8621cd831817d7098cbd1f88586e8ed706118c0b7d9143c748dd05bf3797f4ae78411ae2da92b7a15a84f7ea6e3da6fcdd4e36db7be4a
    HEAD_REF tbb_2019
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
    )

    vcpkg_install_cmake()

    # Settings for TBBConfigInternal.cmake.in
    set(TBB_LIB_EXT a)
    set(TBB_LIB_PREFIX lib)
else()
    if (VCPKG_CRT_LINKAGE STREQUAL static)
        set(RELEASE_CONFIGURATION Release-MT)
        set(DEBUG_CONFIGURATION Debug-MT)
    else()
        set(RELEASE_CONFIGURATION Release)
        set(DEBUG_CONFIGURATION Debug)
    endif()

    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH build/vs2013/makefile.sln
        RELEASE_CONFIGURATION ${RELEASE_CONFIGURATION}
        DEBUG_CONFIGURATION ${DEBUG_CONFIGURATION}
    )
    # Settings for TBBConfigInternal.cmake.in
    set(TBB_LIB_EXT lib)
    set(TBB_LIB_PREFIX)
endif()

file(COPY
  ${SOURCE_PATH}/include/tbb
  ${SOURCE_PATH}/include/serial
  DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Settings for TBBConfigInternal.cmake.in
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(TBB_DEFAULT_COMPONENTS tbb tbbmalloc)
else()
    set(TBB_DEFAULT_COMPONENTS tbb tbbmalloc tbbmalloc_proxy)
endif()

file(READ "${SOURCE_PATH}/include/tbb/tbb_stddef.h" _tbb_stddef)
string(REGEX REPLACE ".*#define TBB_VERSION_MAJOR ([0-9]+).*" "\\1" _tbb_ver_major "${_tbb_stddef}")
string(REGEX REPLACE ".*#define TBB_VERSION_MINOR ([0-9]+).*" "\\1" _tbb_ver_minor "${_tbb_stddef}")
string(REGEX REPLACE ".*#define TBB_INTERFACE_VERSION ([0-9]+).*" "\\1" TBB_INTERFACE_VERSION "${_tbb_stddef}")
set(TBB_VERSION "${_tbb_ver_major}.${_tbb_ver_minor}")
set(TBB_RELEASE_DIR "\${_tbb_root}/lib")
set(TBB_DEBUG_DIR "\${_tbb_root}/debug/lib")

configure_file(
    ${SOURCE_PATH}/cmake/templates/TBBConfigInternal.cmake.in
    ${CURRENT_PACKAGES_DIR}/share/tbb/TBBConfig.cmake
    @ONLY
)
file(READ ${CURRENT_PACKAGES_DIR}/share/tbb/TBBConfig.cmake _contents)
string(REPLACE
    "get_filename_component(_tbb_root \"\${_tbb_root}\" PATH)"
    "get_filename_component(_tbb_root \"\${_tbb_root}\" PATH)\nget_filename_component(_tbb_root \"\${_tbb_root}\" PATH)"
    _contents
    "${_contents}"
)
string(REPLACE
    "set(_tbb_release_lib \"/${TBB_LIB_PREFIX}\${_tbb_component}.${TBB_LIB_EXT}\")"
    "set(_tbb_release_lib \"\${_tbb_root}/lib/${TBB_LIB_PREFIX}\${_tbb_component}.${TBB_LIB_EXT}\")"
    _contents
    "${_contents}"
)
string(REPLACE
    "set(_tbb_debug_lib \"/${TBB_LIB_PREFIX}\${_tbb_component}_debug.${TBB_LIB_EXT}\")"
    "set(_tbb_debug_lib \"\${_tbb_root}/debug/lib/${TBB_LIB_PREFIX}\${_tbb_component}_debug.${TBB_LIB_EXT}\")"
    _contents
    "${_contents}"
)
string(REPLACE "SHARED IMPORTED)" "UNKNOWN IMPORTED)" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/tbb/TBBConfig.cmake "${_contents}")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/tbb)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tbb/LICENSE ${CURRENT_PACKAGES_DIR}/share/tbb/copyright)

vcpkg_test_cmake(PACKAGE_NAME TBB)
#
