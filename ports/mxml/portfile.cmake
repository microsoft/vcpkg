vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO michaelrsweet/mxml
    REF "v${VERSION}"
    SHA512 11ef51b7e8abe8f5b1728ee072217605456e11e56bd0abc5375820c1a0e30ea1a6f0a306e65a40c1cdda3394486b51e2d67cc9081113dbc570b6d9d835f5890f

    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "vcnet/mxml4.vcxproj"
        TARGET Build
    )
    file(INSTALL "${SOURCE_PATH}/mxml.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
else()
    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        COPY_SOURCE
    )
    vcpkg_make_install()
    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
