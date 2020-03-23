vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneTBB
    REF 427c252e0bb9e191767a62d8a744b21950c343f6 # 2020_U1
    SHA512 01307b689680c8d796357a65258257b0c54336aa2a5dc75746d65e169988b8cb353537ad480cc4b8970b32667ab7f965bfedee4a15186f2a3159c9f130667f26
    HEAD_REF tbb_2019
    PATCHES
        fix-static-build.patch
        terminate-when-buildtool-notfound.patch
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

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/tbb)
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
