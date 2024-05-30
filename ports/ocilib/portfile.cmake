vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vrogier/ocilib
    REF "v${VERSION}"
    SHA512 5982b17d04ebbcb281848a998b3f2f35c5a83bc6d14cd6fecb8eef695300b577fb8dcc1377e9a8827587ac06d58441328cb0d55b19ae65788c2fce8da7ce702a
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
