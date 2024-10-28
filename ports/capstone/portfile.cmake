vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "capstone-engine/capstone"
    REF "${VERSION}"
    SHA512 2fd3194dd37065e6091d208c7670b12c0ca6872931eef794bd6b2dd624601c843e8ee6c5714eae0372e394e91a9bc1e4de7dfea6b1087542dd461226569101de
    HEAD_REF next
    PATCHES
        001-silence-windows-crt-secure-warnings.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "arm"         CAPSTONE_ARM_SUPPORT
        "arm64"       CAPSTONE_ARM64_SUPPORT
        "evm"         CAPSTONE_EVM_SUPPORT
        "m680x"       CAPSTONE_M680X_SUPPORT
        "m68k"        CAPSTONE_M68K_SUPPORT
        "mips"        CAPSTONE_MIPS_SUPPORT
        "ppc"         CAPSTONE_PPC_SUPPORT
        "sparc"       CAPSTONE_SPARC_SUPPORT
        "sysz"        CAPSTONE_SYSZ_SUPPORT
        "tms320c64x"  CAPSTONE_TMS320C64X_SUPPORT
        "x86"         CAPSTONE_X86_SUPPORT
        "xcore"       CAPSTONE_XCORE_SUPPORT
        "mos65xx"     CAPSTONE_MOS65XX_SUPPORT
        "tricore"     CAPSTONE_TRICORE_SUPPORT
        "wasm"        CAPSTONE_WASM_SUPPORT
        "bpf"         CAPSTONE_BPF_SUPPORT
        "riscv"       CAPSTONE_RISCV_SUPPORT
        "diet"        CAPSTONE_BUILD_DIET
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCAPSTONE_ARCHITECTURE_DEFAULT=OFF
        -DCAPSTONE_BUILD_TESTS=OFF
        -DCAPSTONE_BUILD_CSTOOL=OFF
        -DCAPSTONE_BUILD_STATIC_RUNTIME=${STATIC_CRT}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
