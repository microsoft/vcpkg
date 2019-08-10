include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libffi/libffi
    REF c2a6859012d928b67a83619bd5087674a96b9254
    SHA512 8639ec9b979bcc59e5a3c063663aedbfb6c1ff0f49a0207ee8a7168d0deebec57255cfff5972c50027ca8276afb6079f0c144a862733de4d3e5a4a917337d007
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
