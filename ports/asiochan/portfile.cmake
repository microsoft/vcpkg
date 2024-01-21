vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MiSo1289/asiochan
    REF 837d7eb78ca9796af800ca3cd91ce0a8fe297785
    SHA512 58e1e3291dc980ed59b0bc1fdcaa35db007e0044f4cbd352917caefa2d30b0c76a3db180091c1895867a3d026ce69f3a82b33dde3970cba5bef596620a2b20f8
    HEAD_REF master
    PATCHES
        fix-build.patch
)

set(VCPKG_BUILD_TYPE release) # header-only
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)