vcpkg_download_distfile(32BIT_PATCH
    URLS "https://github.com/pantoniou/libfyaml/commit/0982fcefc6a16d4c8cb5b06747d3fc8e630de3ae.patch?full_index=1"
    FILENAME "fy_skip_size32.patch"
    SHA512 78071e1e555c531874fec6bd096b9bf8427e6b73436f679a7ef100970ccfdb0fbb0b683242a370b058d1a87f73a008861668b2d81b14a1f9fc77a19b3dbd49ec
)

vcpkg_download_distfile(ARMNEON_PATCH
    URLS "https://github.com/pantoniou/libfyaml/commit/9192deaac095f9881cc1e5756dede683f36b09d6.patch?full_index=1"
    FILENAME "fy_decode_size32.patch"
    SHA512 f47df2c2300c4e634a0b3a9a95f3e70a3c9c6a71d65d0f0096a47debcaede105634c8bf155632c706cab415d6928fc214883ac14574d6e50967429aeba68a2cf
)

vcpkg_download_distfile(ARM_PATCH
    URLS "https://github.com/pantoniou/libfyaml/commit/cd3fd6f666e840051146661969d845f10e31a67c.patch?full_index=1"
    FILENAME "fy_yield.patch"
    SHA512 4721636f9a3f78874893afded87309b09a92c7ab01a72ea226632b0330bcfca9f36a3aebff713a740ebe0f3741f49e7e696850e9a9cae3f3a6e78f5c081d9700
)

vcpkg_download_distfile(ANDROID_PATCH
    URLS "https://github.com/pantoniou/libfyaml/commit/9eca732bee6f18403e96141fa88ffc57d9f7011a.patch?full_index=1"
    FILENAME "fy_pthread.patch"
    SHA512 c2068c3b8ac6101b9821539d5304d412a0a849a9415da8916c5d644d674aafb3c99412309054f1ae327f368bbc9beff4298196c45f447d57b084fdcaff79bf27
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pantoniou/libfyaml
    REF v${VERSION}
    SHA512 e38f42b5d3e5e88300fd1c7b59868592afa5f2f88d30f61e778700c35435ebd14ecef7d82ac0213345dabdb3c562dc234ed1b2bfd84e40b47fdc4f84144c79f5
    PATCHES
        "${32BIT_PATCH}"
        "${ARMNEON_PATCH}"
        "${ARM_PATCH}"
        "${ANDROID_PATCH}"
        "math.diff"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES fy-tool AUTO_CLEAN)

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")