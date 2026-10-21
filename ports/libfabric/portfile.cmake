if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ofiwg/libfabric
    REF v${VERSION}
    SHA512 5dc1c95aa52fd2afb93b0d7b67a5eaf3900ca89cb9dfa5fe4adb7380c2173677e9d1918cb1cf9b127fa3d93c1923bc46af8357461130cb5ca722d5e8c6582cb2
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH libfabric.vcxproj
        RELEASE_CONFIGURATION Release-v142
        DEBUG_CONFIGURATION Debug-v142
        OPTIONS
            "/p:SolutionDir=${SOURCE_PATH}"
    )
    file(COPY "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/libfabric")

else()
    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTORECONF
        OPTIONS
            --with-uring=no
    )
    vcpkg_make_install()
    vcpkg_fixup_pkgconfig()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
