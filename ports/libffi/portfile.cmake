include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libffi/libffi
    REF v3.3-rc2
    SHA512 3470b4f8dcb5529a6b8f8a6bcadb15df5732a973b2e18f016a922e0f17c4961cea6de46dae9eab0f75a9970921e5c23b310b90f4b12355e2ef84592ae1232a38
    HEAD_REF master
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
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
file(READ ${CURRENT_PACKAGES_DIR}/include/ffi.h FFI_H)
string(REPLACE "   *know* they are going to link with the static library.  */"
"   *know* they are going to link with the static library.  */

#define FFI_BUILDING
" FFI_H "${FFI_H}")
file(WRITE ${CURRENT_PACKAGES_DIR}/include/ffi.h "${FFI_H}")
endif()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libffi)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libffi/LICENSE ${CURRENT_PACKAGES_DIR}/share/libffi/copyright)
