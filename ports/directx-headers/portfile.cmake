vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectX-Headers
    REF f9526174f7560f5c96a5a6322039f24ad3c5c8ba
    SHA512 9a6eb8aa30b125c0ef04368cb746156d6fe27aa8b9b54d1f34f3d1b6fb697e2aa7b8f0f8c4e6d1f3ea2aa8b5933a69ce15437a1841c4ba3fb8c0817ec5e601d2
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_build_cmake()
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/directx-headers/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
