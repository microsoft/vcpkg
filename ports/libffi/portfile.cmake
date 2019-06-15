include(vcpkg_common_functions)

# Hopefully the PR will be merged soon
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paulmon/libffi
    REF 20f4c8a7404d4b287edf96d86fd5bd0e6fe14e9c
    SHA512 708bb59cc6024d4d0e1bec81ae107a9aaf9128a61a4be8e76f74b93d16986a5c9beb7fb2e5da27395d92967bea57d563ff62b18281ed9b48c94e661422fb5237
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

file(READ ${CURRENT_PACKAGES_DIR}/include/ffi.h FFI_H)
string(REPLACE "/* *know* they are going to link with the static library. */"
"/* *know* they are going to link with the static library. */

#define FFI_BUILDING

" FFI_H "${FFI_H}")
file(WRITE ${CURRENT_PACKAGES_DIR}/include/ffi.h "${FFI_H}")

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libffi)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libffi/LICENSE ${CURRENT_PACKAGES_DIR}/share/libffi/copyright)
