vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Maratyszcza/fp16
    REF 4dfe081cf6bcd15db339cf2680b9281b8451eeb3
    SHA512 e79a1f6f8d4aeca85982158d5b070923d31d4f2062ed84cfa6f26c47a34f2e8ac49e0f330b7d49f5732d5e1eec6e7afccdac43645070060fb7827e2ce261dd3e
    PATCHES
        find-psimd.patch
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFP16_BUILD_TESTS=OFF
        -DFP16_BUILD_BENCHMARKS=OFF
)
vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
