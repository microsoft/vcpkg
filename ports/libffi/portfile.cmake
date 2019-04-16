include(vcpkg_common_functions)

# Hopefully both PR will be merged soon
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO driver1998/libffi
    REF d4004617c88b706524188046d15720cb9bfa2eec
    SHA512 e4e4f3c09cd8d5112291137e0f00ab8ec276dd8283eaca5519320d96fe00e81d2799b5ff2020b5869fe97df82d0a4783ebd136dfbea77b8c0e0424a0fe20aba3
    HEAD_REF master
    PATCHES
        fix-defines.patch
        fix-arm64-build.patch
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

file(READ ${CURRENT_PACKAGES_DIR}/include/ffi.h FFI_H)
string(REPLACE "/* *know* they are going to link with the static library. */"
"/* *know* they are going to link with the static library. */

#define FFI_BUILDING

" FFI_H "${FFI_H}")
file(WRITE ${CURRENT_PACKAGES_DIR}/include/ffi.h "${FFI_H}")

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libffi)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libffi/LICENSE ${CURRENT_PACKAGES_DIR}/share/libffi/copyright)
