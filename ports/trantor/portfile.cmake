vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-tao/trantor
    REF "v${VERSION}"
    SHA512 3f81d6f1b0360ee35b1c0a3267a7626de9db1ac99009d488e15470d8d1c3da8301e7ff7deeeba0760fa147429dec377361bab3a3f7566d063cd76724b0772e6d
    HEAD_REF master
    PATCHES
        000-fix-deps.patch
        001-disable-werror.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

# Fix CMake files
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Trantor)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/License" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
