vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH QUIC_SOURCE_PATH
    REPO microsoft/msquic
    REF "v${VERSION}"
    SHA512 87bb96bc77c30a39e419be2592199de8f9fa74179852637d2902c50d555bad24d2a664b888434fbc1df461ece69a52097634a47f0edbb78b0b0eed6e5a94033f
    HEAD_REF master
    PATCHES
        fix-install.patch # Adjust install path of build outputs
        fix-uwp-crt.patch # https://github.com/microsoft/msquic/pull/4373
        fix-comparing-system-processor-with-win32.patch # https://github.com/microsoft/msquic/pull/4374
        all_headers.patch
)

# This avoids a link error on x86-windows:
# LINK : fatal error LNK1268: inconsistent option 'NODEFAULTLIB:libucrt.lib' specified with /USEPROFILE but not with /GENPROFILE
file(REMOVE "${QUIC_SOURCE_PATH}/src/bin/winuser/pgo_x86/msquic.pgd")

vcpkg_from_github(
    OUT_SOURCE_PATH OPENSSL_SOURCE_PATH
    REPO quictls/openssl
    REF 612d8e44d687e4b71c4724319d7aa27a733bcbca
    SHA512 ff487d882c2b70ed8915a88ecf0a64724435a96187a7bb3bf401f4a2c4dc572a93f7e788040ccbd29da8bc6ac49ee11550c9d56153262c05fae173ac1d242baa
    HEAD_REF openssl-3.1.5+quic
)

file(REMOVE_RECURSE "${QUIC_SOURCE_PATH}/submodules/openssl")
file(RENAME "${OPENSSL_SOURCE_PATH}" "${QUIC_SOURCE_PATH}/submodules/openssl")

vcpkg_from_github(
    OUT_SOURCE_PATH XDP_WINDOWS
    REPO microsoft/xdp-for-windows
    REF ce228a986fd30049ed58f569d2bf20efffc250f3
    SHA512 4a26c5defe422ef42308d72cf8d1cab1c172ce5a10d8d830c446cb7dd93f0c41f35f3cbbfeceb687d5135272006dd1b1bc4c2089ace4866cede81d5c76206af7
    HEAD_REF main
)

file(REMOVE_RECURSE "${QUIC_SOURCE_PATH}/submodules/xdp-for-windows")
file(RENAME "${XDP_WINDOWS}" "${QUIC_SOURCE_PATH}/submodules/xdp-for-windows")

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH "${PERL}" DIRECTORY)
vcpkg_add_to_path("${PERL_EXE_PATH}")

if(NOT VCPKG_HOST_IS_WINDOWS)
    find_program(MAKE make)
    get_filename_component(MAKE_EXE_PATH "${MAKE}" DIRECTORY)
    vcpkg_add_to_path(PREPEND "${MAKE_EXE_PATH}")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH "${NASM}" DIRECTORY)
    vcpkg_add_to_path(PREPEND "${NASM_EXE_PATH}")
endif()

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${QUIC_SOURCE_PATH}"
    OPTIONS
        -DQUIC_SOURCE_LINK=OFF
        -DQUIC_TLS=openssl
        -DQUIC_USE_SYSTEM_LIBCRYPTO=OFF
        -DQUIC_BUILD_PERF=OFF
        -DQUIC_BUILD_TEST=OFF
        "-DQUIC_STATIC_LINK_CRT=${STATIC_CRT}"
        "-DQUIC_STATIC_LINK_PARTIAL_CRT=${STATIC_CRT}"
        "-DQUIC_UWP_BUILD=${VCPKG_TARGET_IS_UWP}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${QUIC_SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
)
