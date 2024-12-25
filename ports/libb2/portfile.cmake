vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BLAKE2/libb2
    REF 2c5142f12a2cd52f3ee0a43e50a3a76f75badf85
    SHA512 cf29cf9391ae37a978eb6618de6f856f3defa622b8f56c2d5a519ab34fd5e4d91f3bb868601a44e9c9164a2992e80dde188ccc4d1605dffbdf93687336226f8d
    HEAD_REF master
    PATCHES
        fix-msvc-cpuid.patch
)

# Ensure we can detect cpu features on {x64,x86}-windows.
if (VCPKG_HOST_IS_WINDOWS AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86") AND VCPKG_CROSSCOMPILING)
set(pre_run PRERUN_SHELL
    "sed -i 's/cross_compiling=yes/cross_compiling=no/g' configure"
)
endif()

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ax_cv_check_cflags___O3=no # see https://github.com/microsoft/vcpkg/pull/17912#issuecomment-840514179
    ${pre_run}
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
