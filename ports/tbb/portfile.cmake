include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/tbb
    REF 4bdba61bafc6ba2d636f31564f1de5702d365cf7
    SHA512 0b00c9deefdac5dc1f4fbae314e91eb3513b54b47ff6dec08ed2460486fc7d211ab36d6130e5787bfd50523cb613c65f03f9217d967292ca9056e2d3f5010bf8
    HEAD_REF tbb_2019
    PATCHES fix-static-build.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if (NOT VCPKG_TARGET_IS_WINDOWS)
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
    
    macro(CONFIGURE_PROJ_FILE arg)
        set(CONFIGURE_FILE_NAME ${arg})
        set(CONFIGURE_BAK_FILE_NAME ${arg}.bak)
        if (NOT EXISTS ${CONFIGURE_BAK_FILE_NAME})
            configure_file(${CONFIGURE_FILE_NAME} ${CONFIGURE_BAK_FILE_NAME} COPYONLY)
        endif()
        configure_file(${CONFIGURE_BAK_FILE_NAME} ${CONFIGURE_FILE_NAME} COPYONLY)
        if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
            file(READ ${CONFIGURE_FILE_NAME} SLN_CONFIGURE)
            string(REPLACE "<ConfigurationType>DynamicLibrary<\/ConfigurationType>"
                        "<ConfigurationType>StaticLibrary<\/ConfigurationType>" SLN_CONFIGURE "${SLN_CONFIGURE}")
            string(REPLACE "\/D_CRT_SECURE_NO_DEPRECATE"
                        "\/D_CRT_SECURE_NO_DEPRECATE \/DIN_CILK_STATIC" SLN_CONFIGURE "${SLN_CONFIGURE}")
            file(WRITE ${CONFIGURE_FILE_NAME} "${SLN_CONFIGURE}")
        else()
            file(READ ${CONFIGURE_FILE_NAME} SLN_CONFIGURE)
            string(REPLACE "\/D_CRT_SECURE_NO_DEPRECATE"
                        "\/D_CRT_SECURE_NO_DEPRECATE \/DIN_CILK_RUNTIME" SLN_CONFIGURE "${SLN_CONFIGURE}")
            file(WRITE ${CONFIGURE_FILE_NAME} "${SLN_CONFIGURE}")
        endif()
    endmacro()
    
    CONFIGURE_PROJ_FILE(${SOURCE_PATH}/build/vs2013/tbb.vcxproj)
    CONFIGURE_PROJ_FILE(${SOURCE_PATH}/build/vs2013/tbbmalloc.vcxproj)
    CONFIGURE_PROJ_FILE(${SOURCE_PATH}/build/vs2013/tbbmalloc_proxy.vcxproj)

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
    "set(_tbb_release_lib \"/${TBB_LIB_PREFIX}"
    "set(_tbb_release_lib \"\${_tbb_root}/lib/${TBB_LIB_PREFIX}"
    _contents
    "${_contents}"
)
string(REPLACE
    "set(_tbb_debug_lib \"/${TBB_LIB_PREFIX}"
    "set(_tbb_debug_lib \"\${_tbb_root}/debug/lib/${TBB_LIB_PREFIX}"
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
