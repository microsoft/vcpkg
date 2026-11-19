vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO auto-differentiation/xad
    REF "v${VERSION}"
    SHA512 c1da2a795f7eb9b690b2b3bda072b7231b8672b8eec489a31324c42796d36cae791cb34a8119d1ca9d3b42cef6036b7c198538c9b3a80232f6eca1356abf1ce5
    HEAD_REF main
    PATCHES
        fix-install-pdb.patch # no .pdb is produced with /Z7
)

# Build the compiled part of the library for the baseline instruction set of the target.
# The headers are compiled with the consumer's own flags.
if(VCPKG_TARGET_ARCHITECTURE MATCHES "^(x86|x64)$")
    set(XAD_SIMD_OPTION SSE2)
elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(XAD_SIMD_OPTION armv8.0)
else()
    set(XAD_SIMD_OPTION NONE)
endif()

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" XAD_STATIC_MSVC_RUNTIME)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DXAD_ENABLE_TESTS=OFF
        -DXAD_WARNINGS_PARANOID=OFF
        -DXAD_SIMD_OPTION=${XAD_SIMD_OPTION}
        -DXAD_STATIC_MSVC_RUNTIME=${XAD_STATIC_MSVC_RUNTIME}
        # Debug would default it to ON, which changes the tape layout; only the release headers are installed
        -DXAD_TAPE_CHECKS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME XAD CONFIG_PATH lib/cmake/XAD)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
