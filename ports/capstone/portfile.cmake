include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REF e3d5a594eb7e5fabcae4e30db80793e15e1ebace
    REPO "aquynh/capstone"
    SHA512 43b94bb5e8f63f62625444a203cc4bed8b3a445a2400efaae7e5e301c0beb6bad20594b8b1058f6ff0107760ccde82f48ec3e5fa0f30a74236c966eca2728967
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
