include(vcpkg_common_functions)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        message("tbb only supports dynamic library linkage")
        set(VCPKG_LIBRARY_LINKAGE "dynamic")
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO 01org/tbb
    REF 2019_U3
    SHA512 b6eaaea95658c4d49e6894811eb9ca38541820462bf1b606db16ca697af4329a94627d8ae01a73f2b07567280865b3ea92ca0ce091fa95dd3551cebbdd35976d
    HEAD_REF tbb_2018
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
    )

    vcpkg_install_cmake()

    # Settings for TBBConfigForSource.cmake.in
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
    # Settings for TBBConfigForSource.cmake.in
    set(TBB_LIB_EXT lib)
    set(TBB_LIB_PREFIX)
endif()

file(COPY
  ${SOURCE_PATH}/include/tbb
  ${SOURCE_PATH}/include/serial
  DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Settings for TBBConfigForSource.cmake.in
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
    ${SOURCE_PATH}/cmake/templates/TBBConfigForSource.cmake.in
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
string(REPLACE "SHARED IMPORTED)" "UNKNOWN IMPORTED)" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/tbb/TBBConfig.cmake "${_contents}")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/tbb)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tbb/LICENSE ${CURRENT_PACKAGES_DIR}/share/tbb/copyright)

vcpkg_test_cmake(PACKAGE_NAME TBB)
