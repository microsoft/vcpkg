vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REF d5141c04785678535c7792eddc21f146186e639f # 5.0.0-rc2
    REPO "capstone-engine/capstone"
    SHA512 de9cf7da9fc3e502165b28b998b472791c8d5366e1a1a1fabd6bb8856a6fae80bf7d1fc4d268572d69c3526161bb0509a598ad4d94207e25a62aff6a5f9e9404
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
        "osxkernel"   CAPSTONE_OSXKERNEL_SUPPORT
        "ppc"         CAPSTONE_PPC_SUPPORT
        "sparc"       CAPSTONE_SPARC_SUPPORT
        "sysz"        CAPSTONE_SYSZ_SUPPORT
        "tms320c64x"  CAPSTONE_TMS320C64X_SUPPORT
        "x86"         CAPSTONE_X86_SUPPORT
        "x86-reduce"  CAPSTONE_X86_REDUCE
        "xcore"       CAPSTONE_XCORE_SUPPORT
        "diet"        CAPSTONE_BUILD_DIET
)

if ("osxkernel" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_OSX)
    message(FATAL_ERROR "Feature 'osxkernel' only supported in OSX")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
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
