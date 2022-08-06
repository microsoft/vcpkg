vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xz-mirror/xz
    REF v5.2.5
    SHA512 686f01cfe33e2194766a856c48668c661b25eee194a443524f87ce3f866e0eb54914075b4e00185921516c5211db8cd5d2658f4b91f4a3580508656f776f468e
    HEAD_REF master
    PATCHES
        enable-uwp-builds.patch
        fix_config_include.patch
        win_output_name.patch # Fix output name on Windows. Autotool build does not generate lib prefixed libraries on windows. 
        add_support_ios.patch # add install bundle info for support ios 
        build-tools.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")
set(PACKAGE_URL https://tukaani.org/xz/)
set(PACKAGE_VERSION 5.2.5)
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
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
