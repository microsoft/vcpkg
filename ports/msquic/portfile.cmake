vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH QUIC_SOURCE_PATH
    REPO microsoft/msquic
    REF "v${VERSION}"
    SHA512 51afee7e28a7d6ae1b5491edd635e0c88a92a00bacedeaac632a0f19762e9940c9b819a9d33072d3553c004acd4ec0cdf645301f712b408498053de065b2b1cf
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
    REF openssl-3.1.7-quic1
    SHA512 230f48a4ef20bfd492b512bd53816a7129d70849afc1426e9ce813273c01884d5474552ecaede05231ca354403f25e2325c972c9c7950ae66dae310800bd19e7
    HEAD_REF openssl-3.1.7+quic
)

file(REMOVE_RECURSE "${QUIC_SOURCE_PATH}/submodules/openssl3")
file(RENAME "${OPENSSL_SOURCE_PATH}" "${QUIC_SOURCE_PATH}/submodules/openssl3")

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
        -DQUIC_TLS=openssl3
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
