vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tukaani-project/xz
    REF "v${VERSION}"
    SHA512 2f51fb316adb2962e0f2ef6ccc8b544cdc45087b9ad26dcd33f2025784be56578ab937c618e5826b2220b49b79b8581dcb8c6d43cd50ded7ad9de9fe61610f46
    HEAD_REF master
    PATCHES
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
        -DENABLE_NLS=OFF # nls is not supported by this port, yet
        -DXZ_NLS=OFF
    MAYBE_UNUSED_VARIABLES
        CMAKE_MSVC_DEBUG_INFORMATION_FORMAT
        CREATE_XZ_SYMLINKS
        CREATE_LZMA_SYMLINKS
        ENABLE_NLS
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")
set(PACKAGE_URL https://tukaani.org/xz/)
set(PACKAGE_VERSION "${VERSION}")
if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(PTHREAD_CFLAGS -pthread)
endif()
set(prefix "${CURRENT_INSTALLED_DIR}")
configure_file("${SOURCE_PATH}/src/liblzma/liblzma.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/liblzma.pc" @ONLY)
if(NOT VCPKG_BUILD_TYPE)
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

set(TOOLS xz xzdec lzmadec lzmainfo)
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
