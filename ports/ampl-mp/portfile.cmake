vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ampl/mp
    REF bb7d616605dd23e4a453a834b0fc8c0a2a71b5aa
    SHA512 558321f700a2ffe9d13f29f7c034825f5644a49c55da8490160d7ee8303484de5f9a636783387cc108bd238cdc3d2afa6b28cafecce73ee7893d792f5293712a
    HEAD_REF master
    PATCHES
        disable-matlab-mex.patch
        fix-build.patch
        fix-dependency-asl.patch
        fix-arm-build.patch # https://github.com/ampl/mp/issues/115
        install-targets.patch
)

if (VCPKG_TARGET_IS_WINDOWS AND (TRIPLET_SYSTEM_ARCH STREQUAL "arm" OR TRIPLET_SYSTEM_ARCH STREQUAL "arm64"))
    set(EXPECTED_EXE ${CURRENT_INSTALLED_DIR}/../x86-windows/tools/${PORT}/gen-expr-info.exe)
    if (NOT EXISTS ${EXPECTED_EXE})
        message(FATAL_ERROR "Please install ${PORT}:x86-windows first.")
    endif()
    set(ARITHCHK_EXEC ${EXPECTED_EXE})
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD=no
        -DBUILD_TESTING=OFF
        -DMP_VARIADIC_TEMPLATES=OFF
        -DARITHCHK_EXEC=${ARITHCHK_EXEC}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES gen-expr-info AUTO_CLEAN)

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-mp TARGET_PATH share/unofficial-mp)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    # remove amplsig.dll and cp.dll, see https://github.com/ampl/mp/issues/130
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/bin
)

configure_file(${SOURCE_PATH}/LICENSE.rst ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)