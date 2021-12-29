vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(HYPERSCAN_VERSION 5.3.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/hyperscan
    REF v${HYPERSCAN_VERSION}
    SHA512 a4d85ffd2264e8e6745340ba51431361775a1e7a2da78edd31f6f53552ac61fdef718710ae53a254b7d5000f9ec1aafe7a48d9c55e76f5c6822486150bbc6c56
    HEAD_REF master
    PATCHES
        0001-remove-Werror.patch
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS "-DPYTHON_EXECUTABLE=${PYTHON3}"
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_pkgconfig()
