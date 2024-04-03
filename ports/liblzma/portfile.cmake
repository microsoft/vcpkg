vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bminor/xz
    REF "v${VERSION}"
    SHA512 c28461123562564e030f3f733f078bc4c840e87598d9f4b718d4bca639120d8133f969c45d7bdc62f33f081d789ec0f14a1791fb7da18515682bfe3c0c7362e0
    HEAD_REF master
    PATCHES
        fix_config_include.patch
        win_output_name.patch # Fix output name on Windows. Autotool build does not generate lib prefixed libraries on windows. 
        add_support_ios.patch # add install bundle info for support ios 
        build-tools.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "wasm32")
    set(WASM_OPTIONS -DCMAKE_C_BYTE_ORDER=LITTLE_ENDIAN -DCMAKE_CXX_BYTE_ORDER=LITTLE_ENDIAN)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${WASM_OPTIONS}
        -DBUILD_TESTING=OFF
        -DCREATE_XZ_SYMLINKS=OFF
        -DCREATE_LZMA_SYMLINKS=OFF
        -DCMAKE_MSVC_DEBUG_INFORMATION_FORMAT=   # using flags from (vcpkg) toolchain
    MAYBE_UNUSED_VARIABLES
        CMAKE_MSVC_DEBUG_INFORMATION_FORMAT
        CREATE_XZ_SYMLINKS
        CREATE_LZMA_SYMLINKS
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")
set(PACKAGE_URL https://tukaani.org/xz/)
set(PACKAGE_VERSION 5.4.3)
if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(PTHREAD_CFLAGS -pthread)
endif()
set(prefix "${CURRENT_INSTALLED_DIR}")
configure_file("${SOURCE_PATH}/src/liblzma/liblzma.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/liblzma.pc" @ONLY)
if (NOT VCPKG_BUILD_TYPE)
  set(prefix "${CURRENT_INSTALLED_DIR}/debug")
  configure_file("${SOURCE_PATH}/src/liblzma/liblzma.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/liblzma.pc" @ONLY)
endif()
vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/liblzma)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/lzma.h" "defined(LZMA_API_STATIC)" "1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/lzma.h" "defined(LZMA_API_STATIC)" "0")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man"
)

set(TOOLS xz xzdec)
foreach(_tool IN LISTS TOOLS)
    if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        list(REMOVE_ITEM TOOLS ${_tool})
    endif()
endforeach()
if(TOOLS)
    vcpkg_copy_tools(TOOL_NAMES ${TOOLS} AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
