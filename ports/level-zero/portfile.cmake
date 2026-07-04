vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/level-zero
    REF "v${VERSION}"
    SHA512 53f6cc1d41fcf36cee4b8aafca0d069e3a3d71df273affa3a05a3806464c48d0488030596e290bf6d17c0b445cb61954e2c91bac0c176c72341757af2d7354fe
    HEAD_REF master
)

vcpkg_list(SET options)
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_list(APPEND options "-DBUILD_STATIC=1")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/third_party/xla/LICENSE"
)
