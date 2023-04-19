vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

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

if (NOT TARGET_TRIPLET STREQUAL HOST_TRIPLET)
    set(ARITHCHK_EXEC ${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/gen-expr-info${VCPKG_HOST_EXECUTABLE_SUFFIX})
    if (NOT EXISTS "${ARITHCHK_EXEC}")
        message(FATAL_ERROR "Expected ${ARITHCHK_EXEC} to exist.")
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD=no
        -DBUILD_TESTING=OFF
        -DMP_VARIADIC_TEMPLATES=OFF
        -DARITHCHK_EXEC=${ARITHCHK_EXEC}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES gen-expr-info AUTO_CLEAN)

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-mp)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    # remove amplsig.dll and cp.dll, see https://github.com/ampl/mp/issues/130
    "${CURRENT_PACKAGES_DIR}/debug/bin"
    "${CURRENT_PACKAGES_DIR}/bin"
)

configure_file("${SOURCE_PATH}/LICENSE.rst" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
