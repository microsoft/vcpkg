# Current port limitation. More patches needed.
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH QUIC_SOURCE_PATH
    REPO microsoft/msquic
    REF "v${VERSION}"
    SHA512 c6e4b5f5d9b7e92469a6733a99eaf677909a5b2287869f0bbcc61fbcda6db4a6e920b327ede43fc9b1b0a3d09518c568dc1f38ad5fbb3ace14c1c031012b9968
    HEAD_REF master
    PATCHES
        fix-install.patch # Adjust install path of build outputs
        fix-uwp-crt.patch # https://github.com/microsoft/msquic/pull/4373
        fix-comparing-system-processor-with-win32.patch # https://github.com/microsoft/msquic/pull/4374
        uwp-winmm.diff
)

# This avoids a link error on x86-windows:
# LINK : fatal error LNK1268: inconsistent option 'NODEFAULTLIB:libucrt.lib' specified with /USEPROFILE but not with /GENPROFILE
#file(REMOVE "${QUIC_SOURCE_PATH}/src/bin/winuser/pgo_x86/msquic.pgd")

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
        #-DQUIC_TLS=openssl3
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

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${QUIC_SOURCE_PATH}/LICENSE")
