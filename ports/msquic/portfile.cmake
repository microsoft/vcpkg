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
    REF  v1.0.2
    SHA512 1b26487fa79c8796d4b0d5e09f4fc9acb003d8e079189ec57a36ff03c9c2620829106fdbc4780e298872826f3a97f034d40e04d00a77ded97122874d13bfb145
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
