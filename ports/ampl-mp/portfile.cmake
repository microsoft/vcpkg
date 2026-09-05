vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ampl/mp
    REF v${VERSION}
    SHA512 913777afbc9b125207e5c3ad5c01d303b4a772f3569521cb897e7b841a6eb584c4ccec01af459237e2a510303192d3ef95a1756af881058a9cf429f48b4a8808
    HEAD_REF master
    PATCHES
        disable-matlab-mex.patch
        fix-build.patch
        fix-dependency-asl.patch
        fix-arm-build.patch # https://github.com/ampl/mp/issues/115
        install-targets.patch
)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/0007-unofficial-export.cmake" DESTINATION "${SOURCE_PATH}/")

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
        -DBUILD_TESTS=OFF
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
