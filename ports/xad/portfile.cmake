vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO auto-differentiation/xad
    REF "v${VERSION}"
    SHA512 e2e3a847d975dc9fcbd7be8277e93fb417d263aec566f2e46a809135460860caba966980823afb66d764bb0b2eb4d8d24765a8aadadb730aeb743a36b399fbde
    HEAD_REF main
    PATCHES
        fix-install-pdb.patch # no .pdb is produced with /Z7
        fix-msvc-stl-145.patch # Visual Studio 2026 removed stdext::checked_array_iterator
        fix-libcxx-21.patch # upstream 5d8a3b9
)

# The VERSION file in the v2.1.0 tag still carries the "-dev" suffix
file(WRITE "${SOURCE_PATH}/VERSION" "${VERSION}\n")
# Version.hpp.in refers to XAD_VERSION_* while the project defines xad_VERSION_*, which leaves the numeric macros empty
vcpkg_replace_string("${SOURCE_PATH}/src/XAD/Version.hpp.in" "@XAD_VERSION_" "@xad_VERSION_")

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
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME XAD CONFIG_PATH lib/cmake/XAD)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
