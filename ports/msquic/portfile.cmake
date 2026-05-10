# Upstream supports static linkage, but the port doesn't:
# - There is a vendored fork of OpenSSL, needed for QUIC.
# - Exported config needs fixes.
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH QUIC_SOURCE_PATH
    REPO microsoft/msquic
    REF "v${VERSION}"
    SHA512 49f063091052c7150ca20cd3f0b1a49739f810f97dd79487b5404873a3bf206253fa266fd74a3678ba58968a1a42c39f77fbeb9a3780cffcf9e8944adb82e8e5
    HEAD_REF master
    PATCHES
        fix-uwp-crt.patch # https://github.com/microsoft/msquic/pull/4373
        uwp-link-libs.diff
        exports-for-msh3.diff
        no-werror.patch
        cmake4.patch
)

set(QUIC_TLS "schannel")
if("0-rtt" IN_LIST FEATURES)
    set(QUIC_TLS "quictls")
    vcpkg_from_github(
        OUT_SOURCE_PATH OPENSSL_SOURCE_PATH
        REPO quictls/openssl
        REF ff36838bb69801cad56823159a036977bcbe5c75
        SHA512 9cf52fbb0c6d88048a875569427c0982dffd2b861bf2299e64a4a088e17188b2b4a3d46472997a45e62acd5d3bb210ab8c0f1e84a3425de9b0ecba9bf96c4652
        HEAD_REF openssl-3.1.7+quic
    )
    if(NOT EXISTS "${QUIC_SOURCE_PATH}/submodules/openssl3/Configure")
        file(REMOVE_RECURSE "${QUIC_SOURCE_PATH}/submodules/quictls")
        file(RENAME "${OPENSSL_SOURCE_PATH}" "${QUIC_SOURCE_PATH}/submodules/quictls")
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH XDP_WINDOWS
    REPO microsoft/xdp-for-windows
    REF  793dc2a0d7e6f8a86dae06c84de7d8fd6eacd205
    SHA512 28a6ab43602998991dcf0485f34100ae5f031ec5219ba7d78fc2bc652730697a829fc12bd7ed2281b42ff8f91c006b4f947d3b0cc69c8caabc030ecc1ce9a00c
    HEAD_REF main
)
if(NOT EXISTS "${QUIC_SOURCE_PATH}/submodules/xdp-for-windows/published/external")
    # headers only
    file(REMOVE_RECURSE "${QUIC_SOURCE_PATH}/submodules/xdp-for-windows")
    file(COPY "${XDP_WINDOWS}/published/external" DESTINATION "${QUIC_SOURCE_PATH}/submodules/xdp-for-windows/published")
endif()

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH "${PERL}" DIRECTORY)
vcpkg_add_to_path("${PERL_EXE_PATH}")

if(VCPKG_HOST_IS_WINDOWS)
    vcpkg_find_acquire_program(JOM)
    cmake_path(GET JOM PARENT_PATH jom_dir)
    vcpkg_add_to_path("${jom_dir}")
else()
    find_program(MAKE make)
    cmake_path(GET MAKE PARENT_PATH make_dir)
    vcpkg_add_to_path("${make_dir}")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(NASM)
    cmake_path(GET NASM PARENT_PATH nasm_dir)
    vcpkg_add_to_path("${nasm_dir}")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" QUIC_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${QUIC_SOURCE_PATH}"
    OPTIONS
        -DQUIC_SOURCE_LINK=OFF
        -DQUIC_TLS_LIB=${QUIC_TLS}
        -DQUIC_USE_SYSTEM_LIBCRYPTO=OFF
        -DQUIC_BUILD_PERF=OFF
        -DQUIC_BUILD_TEST=OFF
        "-DQUIC_BUILD_SHARED=${QUIC_BUILD_SHARED}"
        "-DQUIC_STATIC_LINK_CRT=${STATIC_CRT}"
        "-DQUIC_STATIC_LINK_PARTIAL_CRT=${STATIC_CRT}"
        "-DQUIC_UWP_BUILD=${VCPKG_TARGET_IS_UWP}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

# Convert absolute paths to relative paths
file(GLOB MSQUIC_CMAKE_FILES "${CURRENT_PACKAGES_DIR}/share/msquic/*.cmake")
foreach(MSQUIC_CMAKE_FILE ${MSQUIC_CMAKE_FILES})
    file(READ "${MSQUIC_CMAKE_FILE}" MSQUIC_CMAKE_CONTENT)
    string(REGEX REPLACE
        "/[^;\"]*buildtrees/msquic/([^;\"]*)"
        "\${_IMPORT_PREFIX}/../../buildtrees/msquic/\\1"
        MSQUIC_CMAKE_CONTENT "${MSQUIC_CMAKE_CONTENT}")
    file(WRITE "${MSQUIC_CMAKE_FILE}" "${MSQUIC_CMAKE_CONTENT}")
endforeach()

set(platform "")
if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    set(platform "CX_PLATFORM_DARWIN")
elseif(NOT VCPKG_TARGET_IS_WINDOWS)
    set(platform "CX_PLATFORM_LINUX")
endif()
if(platform)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/quic_platform.h"
        "#elif ${platform}"
        "#elif 1
#ifndef ${platform}
#define ${platform}
#endif")
elseif(VCPKG_TARGET_IS_UWP)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/quic_platform.h"
        "#elif _WIN32"
        "#elif 1
#ifndef QUIC_UWP_BUILD
#define QUIC_UWP_BUILD
#endif
#ifndef QUIC_RESTRICTED_BUILD
#define QUIC_RESTRICTED_BUILD
#endif")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${QUIC_SOURCE_PATH}/LICENSE" "${QUIC_SOURCE_PATH}/THIRD-PARTY-NOTICES")
