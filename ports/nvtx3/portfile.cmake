vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/NVTX
    REF v${VERSION}
    SHA512 46c5c11db52d8ce372d7372c02518916e9e946d4976f61d72b430035458e8c48a1c8ea06b1b6825057233cd8e453362f40f22cfd77cc19947c87f06e0420bc9f
    HEAD_REF release-v3
)

# header-only library. we don't need other configurations
set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/c"
    OPTIONS
        -DNVTX3_TARGETS_NOT_USING_IMPORTED=ON
        -DNVTX3_INSTALL=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/nvtx3")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)
file(INSTALL "${SOURCE_PATH}/c/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
