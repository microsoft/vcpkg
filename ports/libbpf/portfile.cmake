vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libbpf/libbpf
    REF "v${VERSION}"
    SHA512 29996f76d45222070b7554c1a098d67cf0933876a0fb3965800a304239a7e8dcc4d2ecc3ffe049dfbebe62e29e12cca793c6b22d5845955dd17faff5786691dd
    HEAD_REF master
    PATCHES
        0001-enable-static-or-shared.patch
        0002-fix-dependency-lookup.patch
)

find_program(MAKE make REQUIRED)

set(OPTIONS "")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND OPTIONS "BUILD_STATIC_ONLY=y")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(COPY "${SOURCE_PATH}/" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/")
    z_vcpkg_setup_pkgconfig_path(CONFIG RELEASE)

    vcpkg_execute_build_process(
        COMMAND
            "${MAKE}"
            "install"
            "-j${VCPKG_CONCURRENCY}"
            "PREFIX=${CURRENT_PACKAGES_DIR}"
            "LIBDIR=${CURRENT_PACKAGES_DIR}/lib"
            ${OPTIONS}
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src"
        LOGNAME "make-install-${TARGET_TRIPLET}-rel"
    )

    z_vcpkg_restore_pkgconfig_path()
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(COPY "${SOURCE_PATH}/" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/")
    z_vcpkg_setup_pkgconfig_path(CONFIG DEBUG)

    vcpkg_execute_build_process(
        COMMAND
            "${MAKE}"
            "install"
            "-j${VCPKG_CONCURRENCY}"
            "PREFIX=${CURRENT_PACKAGES_DIR}/debug"
            "LIBDIR=${CURRENT_PACKAGES_DIR}/debug/lib"
            ${OPTIONS}
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src"
        LOGNAME "make-install-${TARGET_TRIPLET}-dbg"
    )

    z_vcpkg_restore_pkgconfig_path()
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/LICENSE.LGPL-2.1"
    "${SOURCE_PATH}/LICENSE.BSD-2-Clause"
)

