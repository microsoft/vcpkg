set(VERSION 3.3)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libffi/libffi
    REF v3.3
    SHA512 62798fb31ba65fa2a0e1f71dd3daca30edcf745dc562c6f8e7126e54db92572cc63f5aa36d927dd08375bb6f38a2380ebe6c5735f35990681878fc78fc9dbc83
    HEAD_REF master
    PATCHES
        win64-disable-stackframe-check.patch
        win32-disable-stackframe-check.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libffiConfig.cmake.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFFI_CONFIG_FILE=${CMAKE_CURRENT_LIST_DIR}/fficonfig.h
    OPTIONS_DEBUG
        -DFFI_SKIP_HEADERS=ON
)

vcpkg_install_cmake()

# Create pkgconfig file
set(PACKAGE_VERSION ${VERSION})
set(prefix "${CURRENT_INSTALLED_DIR}")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(toolexeclibdir "\${libdir}")
set(includedir "\${prefix}/include")
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    configure_file("${SOURCE_PATH}/libffi.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libffi.pc" @ONLY)
endif()
# debug
set(prefix "${CURRENT_INSTALLED_DIR}/debug")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(toolexeclibdir "\${libdir}")
set(includedir "\${prefix}/../include")
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    configure_file("${SOURCE_PATH}/libffi.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libffi.pc" @ONLY)
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()
if(VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libffi.pc
        "-lffi" "-llibffi")
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libffi.pc
        "-lffi" "-llibffi")
endif()
vcpkg_fixup_pkgconfig()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/ffi.h
        "   *know* they are going to link with the static library.  */"
        "   *know* they are going to link with the static library.  */

#define FFI_BUILDING
"
    )
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
