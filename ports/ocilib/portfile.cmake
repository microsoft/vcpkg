vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vrogier/ocilib
    REF "v${VERSION}"
    SHA512 310c25fbe47ab59570103afdc6f4517b979d4077c77665c931592d95e8c706dcf34d5c2f10309a9971534499b2c4367efd05b25cdf8ebd4de15cb2c104059760
    HEAD_REF master
    PATCHES fix-DisableWC4191.patch
)


if(VCPKG_TARGET_IS_WINDOWS)
    # There is no debug configuration
    # As it is a C library, build the release configuration and copy its output to the debug folder
    set(VCPKG_BUILD_TYPE release)
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH proj/dll/ocilib_dll.sln
        INCLUDES_SUBPATH include
        LICENSE_SUBPATH LICENSE
        RELEASE_CONFIGURATION "Release - ANSI"
        PLATFORM "${VCPKG_TARGET_ARCHITECTURE}"
        USE_VCPKG_INTEGRATION
        ALLOW_ROOT_INCLUDES)

    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug")
    file(COPY "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    endif()
else()
    vcpkg_configure_make(
        COPY_SOURCE
        AUTOCONFIG
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            --with-oracle-import=runtime
    )

    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
    file(RENAME "${CURRENT_PACKAGES_DIR}/share/doc/${PORT}" "${CURRENT_PACKAGES_DIR}/share/${PORT}")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")
    file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
