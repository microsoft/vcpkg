include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REF 120373dc9789875ccbc968397219a86598a4351e
    REPO "aquynh/capstone"
    SHA512 90961176ab68110b0fea08f11a5ed6997dcd92ceeec568978003bfd01e2170479256f137e4f91be5e22a9bdebbe1f436c2849bde1d4e0bbd0b781f8562b58059
    HEAD_REF v4
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" CS_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CS_BUILD_SHARED)


function(check_feature name var)
    set(${var} OFF PARENT_SCOPE)
    if (${name} IN_LIST FEATURES)
        set(${var} ON PARENT_SCOPE)
    endif ()
endfunction ()


check_feature("arm"         WITH_ARM_SUPPORT)
check_feature("arm64"       WITH_ARM64_SUPPORT)
check_feature("evm"         WITH_EVM_SUPPORT)
check_feature("m680x"       WITH_M680X_SUPPORT)
check_feature("m68k"        WITH_M68K_SUPPORT)
check_feature("mips"        WITH_MIPS_SUPPORT)
check_feature("osxkernel"   WITH_OSXKERNEL_SUPPORT)
check_feature("ppc"         WITH_PPC_SUPPORT)
check_feature("sparc"       WITH_SPARC_SUPPORT)
check_feature("sysz"        WITH_SYSZ_SUPPORT)
check_feature("tms320c64x"  WITH_C64X_SUPPORT)
check_feature("x86"         WITH_X86_SUPPORT)
check_feature("x86_reduce"  WITH_X86_REDUCE)
check_feature("xcore"       WITH_XCORE_SUPPORT)

check_feature("diet"  CS_BUILD_DIET)

if (WITH_X86_REDUCE AND NOT WITH_X86_SUPPORT)
    set(WITH_X86_SUPPORT ON)
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCAPSTONE_BUILD_STATIC=${CS_BUILD_STATIC}
        -DCAPSTONE_BUILD_SHARED=${CS_BUILD_SHARED}
        -DCAPSTONE_BUILD_DIET=${CS_BUILD_DIET}
        -DCAPSTONE_BUILD_TESTS=OFF
        -DCAPSTONE_BUILD_CSTOOL=OFF
        -DCAPSTONE_BUILD_STATIC_RUNTIME=OFF

        -DCAPSTONE_ARM_SUPPORT=${WITH_ARM_SUPPORT}
        -DCAPSTONE_ARM64_SUPPORT=${WITH_ARM64_SUPPORT}
        -DCAPSTONE_EVM_SUPPORT=${WITH_EVM_SUPPORT}
        -DCAPSTONE_M680X_SUPPORT=${WITH_M680X_SUPPORT}
        -DCAPSTONE_M68K_SUPPORT=${WITH_M68K_SUPPORT}
        -DCAPSTONE_MIPS_SUPPORT=${WITH_MIPS_SUPPORT}
        -DCAPSTONE_OSXKERNEL_SUPPORT=${WITH_OSXKERNEL_SUPPORT}
        -DCAPSTONE_PPC_SUPPORT=${WITH_PPC_SUPPORT}
        -DCAPSTONE_SPARC_SUPPORT=${WITH_SPARC_SUPPORT}
        -DCAPSTONE_SYSZ_SUPPORT=${WITH_SYSZ_SUPPORT}
        -DCAPSTONE_TMS320C64X_SUPPORT=${WITH_C64X_SUPPORT}
        -DCAPSTONE_X86_SUPPORT=${WITH_X86_SUPPORT}
        -DCAPSTONE_XCORE_SUPPORT=${WITH_XCORE_SUPPORT}

        -DCAPSTONE_X86_REDUCE=${WITH_X86_REDUCE}
        -DCAPSTONE_X86_ONLY=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(GLOB EXES ${CURRENT_PACKAGES_DIR}/bin/*.exe ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
if(EXES)
    file(REMOVE ${EXES})
endif()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/capstone
    RENAME copyright)
