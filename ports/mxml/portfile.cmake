vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO michaelrsweet/mxml
    REF "v${VERSION}"
    SHA512 11ef51b7e8abe8f5b1728ee072217605456e11e56bd0abc5375820c1a0e30ea1a6f0a306e65a40c1cdda3394486b51e2d67cc9081113dbc570b6d9d835f5890f

    HEAD_REF master
)

# Build:
IF(VCPKG_HOST_IS_WINDOWS)
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "vcnet/mxml4.vcxproj"
        TARGET Build
    )
ELSE()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
    )
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
ENDIF()

file(INSTALL "${SOURCE_PATH}/mxml.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
