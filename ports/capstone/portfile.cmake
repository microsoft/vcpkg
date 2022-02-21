vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REF 4.0.2
    REPO "aquynh/capstone"
    SHA512 7f93534517307b737422a8825b66b2a1f3e1cca2049465d60ab12595940154aaf843ba40ed348fce58de58b990c19a0caef289060eb72898cb008a88c470970e
    HEAD_REF v4
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" CS_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CS_BUILD_SHARED)
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
        -DCAPSTONE_BUILD_STATIC=${CS_BUILD_STATIC}
        -DCAPSTONE_BUILD_SHARED=${CS_BUILD_SHARED}
        -DCAPSTONE_BUILD_TESTS=OFF
        -DCAPSTONE_BUILD_CSTOOL=OFF
        -DCAPSTONE_X86_ONLY=OFF
        -DCAPSTONE_BUILD_STATIC_RUNTIME=${STATIC_CRT}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe" "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
if(EXES)
    file(REMOVE ${EXES})
endif()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
