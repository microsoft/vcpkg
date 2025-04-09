vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vrogier/ocilib
    REF "v${VERSION}"
    SHA512 8a2c716ceba5c941d2f55ca99ba2b563bc754f2e7a8b6632421a62b3b2a298afb9a05ae13a1997995cea811c36f737ae1e0e5c676d72f573dbebc7f5073c8206
    HEAD_REF master
    PATCHES fix-DisableWC4191.patch
)


if(VCPKG_TARGET_IS_WINDOWS)
    # There is no debug configuration
    # As it is a C library, build the release configuration and copy its output to the debug folder
    set(VCPKG_BUILD_TYPE release)
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH proj/dll/ocilib_dll.sln
        RELEASE_CONFIGURATION "Release - ANSI"
        PLATFORM ${VCPKG_TARGET_ARCHITECTURE}
    )

    file(COPY "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

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
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
