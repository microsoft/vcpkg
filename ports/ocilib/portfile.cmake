vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vrogier/ocilib
    REF v4.7.3
    SHA512 80cf1f76420b506789b1f7edd9af826801236499dd0757be3438e3cdf286b95ddd7dd35909622b3862244f6b535a8744f0b25989fb3740a4a0fd984410fb420b
    HEAD_REF master
    PATCHES fix-DisableWC4191.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(PLATFORM x86)
    else()
        set(PLATFORM x64)
    endif()

    # There is no debug configuration
    # As it is a C library, build the release configuration and copy its output to the debug folder
    set(VCPKG_BUILD_TYPE release)
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH proj/dll/ocilib_dll_vs2019.sln
        INCLUDES_SUBPATH include
        LICENSE_SUBPATH LICENSE
        RELEASE_CONFIGURATION "Release - ANSI"
        PLATFORM ${PLATFORM}
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
